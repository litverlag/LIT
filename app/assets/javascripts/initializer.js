/**
 * Initialization when Document is loaded
 */


$(document).on('ready page:load',
    function () {

        //Deadlines get filled in automatically in the projekt edit view
        scheduler();
        // Help message for the "titelei_versand_an_zur_ueberpf" which dissapers when focued on
        textbox_info();
        textbox_info_submit();
        //Changes the number field standard error message given by the HTML5 type= number
        number_field_error_msg();
        //changes the format in the datepickers
        datepicker_format();
        // checkbox logic for the admin_views
        check_box_lek();
        check_box_dep();
        admin_users_input();
        //Slides the Panels in the shwo views
        slider();
		//checkbox logic for freigabe
		//check_box_frei();


        $(".ui-helper-hidden-accessible").remove();
    });

