$(document).ready(function () {
    if ($("input#document_use_editor_true").prop("checked") == true) {
        $("div#document_editor_field").show();
        $("div#document_upload_field").hide();
    } else if ($('input#document_use_editor_false').prop("checked") == true) {
        $("div#document_editor_field").hide();
        $("div#document_upload_field").show();
    } else {
        $("div#document_editor_field").hide();
        $("div#document_upload_field").hide();
    }

    $("input#document_use_editor_true").change(function () {
        $("div#document_editor_field").show();
        $("div#document_upload_field").hide();
    });

    $("input#document_use_editor_false").change(function () {
        $("div#document_editor_field").hide();
        $("div#document_upload_field").show();
    });

    if ($("input#document_assigned_to_all_false").prop("checked") == true) {
        $("div#user_selection").show();
    } else {
        $("div#user_selection").hide();
    }

    $("input#document_assigned_to_all_true").change(function () {
        $("div#user_selection").hide();
    });

    $("input#document_assigned_to_all_false").change(function () {
        $("div#user_selection").show();
    });

    $("#document_filter_buttons li").click(function () {
        $(this).addClass("active");
        $(this).siblings("li").each(function () {
            $(this).removeClass("active");
        });
    });

    $("#status_filter_buttons input").click(function () {
        $(this).addClass("active btn-warning");
        $(this).siblings("input").each(function () {
            $(this).removeClass("active btn-warning");
        });
    });
});