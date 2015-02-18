$(document).ready(function () {
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