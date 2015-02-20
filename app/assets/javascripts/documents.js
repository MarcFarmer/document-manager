$(document).ready(function () {
    if ($('input#document_assigned_to_all_false').prop("checked") == true) {
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