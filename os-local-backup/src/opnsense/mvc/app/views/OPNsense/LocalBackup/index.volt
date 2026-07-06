<div class="content-box">
    <div class="container-fluid">
        <div class="row">
            <div class="col-xs-12">
                <div class="tab-content content-box">
                    <div id="status" class="tab-pane fade in active">
                        <div class="content-box-main">
                            <div class="table-responsive">
                                <table class="table table-striped">
                                    <thead>
                                        <tr>
                                            <th>{{ lang._('Status Information') }}</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>{{ lang._('Location') }}</td>
                                            <td id="info_location"></td>
                                        </tr>
                                        <tr>
                                            <td>{{ lang._('Current free space') }}</td>
                                            <td id="info_free_space"></td>
                                        </tr>
                                        <tr>
                                            <td>{{ lang._('Number of backups') }}</td>
                                            <td id="info_count"></td>
                                        </tr>
                                        <tr>
                                            <td>{{ lang._('Backup schedule') }}</td>
                                            <td id="info_schedule"></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-xs-12">
                <div class="pull-right">
                    <button class="btn btn-primary" id="btn_backup_now" type="button">
                        <b>{{ lang._('Create backup now') }}</b> <i id="btn_backup_now_progress" class="fa fa-plus"></i>
                    </button>
                    <button class="btn btn-default" id="btn_refresh" type="button">
                        <b>{{ lang._('Refresh') }}</b> <i class="fa fa-refresh"></i>
                    </button>
                </div>
            </div>
        </div>

        <hr/>

        <div class="row">
            <div class="col-xs-12">
                <table id="grid-backups" class="table table-condensed table-hover table-striped" data-editDialog="false">
                    <thead>
                        <tr>
                            <th data-column-id="filename" data-type="string">{{ lang._('Filename') }}</th>
                            <th data-column-id="size" data-type="numeric" data-formatter="formatSize">{{ lang._('Size') }}</th>
                            <th data-column-id="date" data-type="string">{{ lang._('Date') }}</th>
                            <th data-column-id="commands" data-formatter="commands" data-sortable="false">{{ lang._('Actions') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<div class="content-box" style="margin-top: 10px;">
    {{ partial("layout_partials/base_form",['fields':generalForm,'id':'form_general'])}}
    <div class="container-fluid">
        <div class="row">
            <div class="col-xs-12">
                <button class="btn btn-primary" id="btn_save" type="button">
                    <b>{{ lang._('Save Settings') }}</b> <i class="fa fa-save"></i>
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
        var data_get_map = {'form_general': "/api/localbackup/settings/get"};

        function updateStatus() {
            ajaxGet("/api/localbackup/service/list", {}, function(data, status) {
                if (status == "success") {
                    $("#info_location").text(data.location);
                    $("#info_free_space").text((data.free_space / (1024*1024*1024)).toFixed(2) + " GB");
                    $("#info_count").text(data.count);

                    $("#grid-backups tbody").empty();
                    $.each(data.backups, function(index, backup) {
                        var row = '<tr>';
                        row += '<td>' + backup.filename + '</td>';
                        row += '<td>' + (backup.size / 1024).toFixed(2) + ' KB</td>';
                        row += '<td>' + backup.date + '</td>';
                        row += '<td>';
                        row += '<button class="btn btn-xs btn-default btn_download" data-filename="' + backup.filename + '"><i class="fa fa-download"></i></button> ';
                        row += '<button class="btn btn-xs btn-default btn_restore" data-filename="' + backup.filename + '"><i class="fa fa-undo"></i></button> ';
                        row += '<button class="btn btn-xs btn-default btn_delete" data-filename="' + backup.filename + '"><i class="fa fa-trash"></i></button>';
                        row += '</td>';
                        row += '</tr>';
                        $("#grid-backups tbody").append(row);
                    });
                }
            });

            ajaxGet("/api/localbackup/settings/get", {}, function(data, status) {
                if (status == "success") {
                    var sched = data.general.hour + ":" + (data.general.minute < 10 ? "0" : "") + data.general.minute;
                    if (data.general.enabled == "1") {
                        $("#info_schedule").text("Daily at " + sched);
                    } else {
                        $("#info_schedule").text("Disabled");
                    }
                }
            });
        }

        mapDataToFormUI(data_get_map).done(function() {
            formatTokenizersUI();
            $('.selectpicker').selectpicker('refresh');
            updateStatus();
        });

        $("#btn_save").click(function() {
            saveFormToEndpoint("/api/localbackup/settings/set", 'form_general', function() {
                ajaxCall("/api/localbackup/service/reconfigure", {}, function(data, status) {
                    updateStatus();
                });
            });
        });

        $("#btn_backup_now").click(function() {
            $("#btn_backup_now_progress").addClass("fa-spinner fa-pulse").removeClass("fa-plus");
            ajaxCall("/api/localbackup/service/backup", {}, function(data, status) {
                $("#btn_backup_now_progress").addClass("fa-plus").removeClass("fa-spinner fa-pulse");
                if (data.status != "OK") {
                    BootstrapDialog.show({
                        type: BootstrapDialog.TYPE_DANGER,
                        title: '{{ lang._('Backup') }}',
                        message: '{{ lang._('Error creating backup') }}'
                    });
                }
                updateStatus();
            });
        });

        $("#btn_refresh").click(function() {
            updateStatus();
        });

        $(document).on("click", ".btn_download", function() {
            window.location.href = "/api/localbackup/service/download/" + $(this).data('filename');
        });

        $(document).on("click", ".btn_delete", function() {
            var filename = $(this).data('filename');
            BootstrapDialog.confirm({
                title: '{{ lang._('Confirmation') }}',
                message: '{{ lang._('Are you sure you want to delete this backup?') }} (' + filename + ')',
                type: BootstrapDialog.TYPE_DANGER,
                callback: function(result) {
                    if (result) {
                        ajaxCall("/api/localbackup/service/delete/" + filename, {}, function(data, status) {
                            if (data.status != "OK") {
                                BootstrapDialog.show({
                                    type: BootstrapDialog.TYPE_DANGER,
                                    title: '{{ lang._('Delete') }}',
                                    message: '{{ lang._('Error deleting backup') }}'
                                });
                            }
                            updateStatus();
                        });
                    }
                }
            });
        });

        $(document).on("click", ".btn_restore", function() {
            var filename = $(this).data('filename');
            BootstrapDialog.confirm({
                title: '{{ lang._('Confirmation') }}',
                message: '{{ lang._('Are you sure you want to restore this backup? The system will reboot automatically.') }} (' + filename + ')',
                type: BootstrapDialog.TYPE_WARNING,
                callback: function(result) {
                    if (result) {
                        ajaxCall("/api/localbackup/service/restore/" + filename, {}, function(data, status) {
                            BootstrapDialog.show({
                                title: '{{ lang._('Restore') }}',
                                message: '{{ lang._('The configuration has been restored. The system is now rebooting.') }}'
                            });
                        });
                    }
                }
            });
        });
    });
</script>
