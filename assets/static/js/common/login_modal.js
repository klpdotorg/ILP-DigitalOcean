/*
    Handles JS for login modal, including login, sign-up and forgot password
 */
(function() {
    var t = klp.login_modal = {};
    var postLoginCallback = null;
    t.open = function(callback) {
        postLoginCallback = callback;
        klp.openModal = t;
        $('#signupModalTrigger').click();
    };

    t.close = function() {
        //showSignup();
        $('.closeLightBox').click();
    };

    t.afterClose = function() {
        klp.utils.clearForm('signupForm');
        klp.utils.clearForm('loginForm');
        klp.utils.clearForm('forgotPasswordForm');
        klp.utils.clearForm('otpForm');
        klp.utils.clearForm('forgotPasswordOTPForm')
        postLoginCallback = null;
    };

    t.init = function() {
        $('#signupModalTrigger').rbox({
            'type': 'inline',
            inline: '#loginModalTemplate',
            onopen: initModal,
            onclose: t.afterClose
        });

    };

    function initModal() {
        $('#signupForm').submit(submitSignup);
        $('#signupFormSubmit').click(function(e) {
            e.preventDefault();
            $('#signupForm').submit();
        });

        $('#loginForm').submit(submitLogin);
        $('#loginFormSubmit').click(function(e) {
            e.preventDefault();
            $('#loginForm').submit();
        });

        $('#forgotPasswordForm').submit(submitForgotPassword);
        $('#forgotPasswordFormSubmit').click(function(e) {
            e.preventDefault();
            $('#forgotPasswordForm').submit();
        });

        $('#signupOtpForm').submit(submitSignupOtp);
        $('#signupOtpFormSubmit').click(function(e) {
            e.preventDefault();
            $('#signupOtpForm').submit();
        });

        $('#forgotPasswordOTPForm').submit(submitPasswordOtpForm);
        $('#forgotPasswordOtpFormSubmit').click(function(e) {
            e.preventDefault();
            $('#forgotPasswordOTPForm').submit();
        });

        $('.js-showLogin').click(showLogin);
        $('.js-showSignup').click(showSignup);
        $('.js-showForgotPassword').click(showForgotPassword);

        showLogin();
    }

    function showSignup(e) {
        if (e) {
            e.preventDefault();
        }
        $('#loginContainer').hide();
        $('#forgotPasswordContainer').hide();
        $('#signupOtpContainer').hide();
        $('#signupContainer').show();
    }


    function showForgotPasswordOTP(e, mobile_no) {
        if (e) {
            e.preventDefault();
        }
        $('#loginContainer').hide();
        $('#signupContainer').hide();
        $('#signupOtpContainer').hide();
        $('#forgotPasswordContainer').hide();
        $('#forgotPasswordOTPContainer').show();
        $('#forgotPasswordOtpMobile').val(mobile_no);
    }


    function showSignupOTP(e, userData) {
        if (e) {
            e.preventDefault();
        }

        if(userData && userData.mobile_no) {
            $('#signupOtpMobile').val(userData.mobile_no);
        }

        $('#loginContainer').hide();
        $('#forgotPasswordContainer').hide();
        $('#signupContainer').hide();
        $('#signupOtpContainer').show();
    }

    function showForgotPassword(e) {
        if (e) {
            e.preventDefault();
        }
        $('#loginContainer').hide();
        $('#signupContainer').hide();
        $('#signupOtpContainer').hide();
        $('#forgotPasswordContainer').show();
    }

    function showLogin(e, successMessage) {
        if (e) {
            e.preventDefault();
        }

        if(successMessage) {
            $('#loginOtpVerifiedMessage').html(successMessage).show();
        } else {
            $('#loginOtpVerifiedMessage').hide();
        }

        $('#signupContainer').hide();
        $('#signupOtpContainer').hide();
        $('#forgotPasswordContainer').hide();
        $('#forgotPasswordOTPContainer').hide();
        $('#loginContainer').show();
    }

    function submitSignup(e) {
        if (e) {
            e.preventDefault();
        }
        var formID = 'signupForm';
        klp.utils.clearValidationErrors(formID);
        var isValid = klp.utils.validateRequired(formID);
        if (isValid) {
            var fields = {
                'first_name': $('#signupFirstName'),
                'last_name': $('#signupLastName'),
                'mobile_no': $('#signupPhone'),
                'email': $('#signupEmail'),
                'password': $('#signupPassword'),
                'opted_email': $('#signupOptedEmail')
            };
            var data = klp.utils.getFormData(fields);

            klp.utils.startSubmit(formID);
            var signupXHR = klp.api.signup(data);

            signupXHR.done(function(userData) {
                klp.utils.stopSubmit(formID);
                showSignupOTP(null, userData);
            });

            signupXHR.fail(function(err) {
                //FIXME: deal with errors
                // console.log("signup error", err);
                klp.utils.stopSubmit(formID);
                var errors = JSON.parse(err.responseText);
                if ('detail' in errors && errors.detail === 'duplicate email') {
                    var $field = fields.email;
                    klp.utils.invalidateField($field, "This email address already exists.");
                } else {
                    klp.utils.invalidateErrors(fields, errors);
                }
                //alert("error signing up");
            });
        }
    }

    function submitLogin(e) {
        if (e) {
            e.preventDefault();
        }
        var formID = 'loginForm';
        klp.utils.clearValidationErrors(formID);
        var isValid = klp.utils.validateRequired('loginForm');
        if (isValid) {
            var data = {
                'username': $('#loginUsername').val(),
                'password': $('#loginPassword').val()
            };
            var loginXHR = klp.api.login(data);
            klp.utils.startSubmit(formID);
            loginXHR.done(function(userData) {
                klp.utils.stopSubmit(formID);
                klp.auth.loginUser(userData);
                klp.utils.alertMessage("Logged in successfully!", "success");
                if (postLoginCallback) {
                    postLoginCallback();
                }
                t.close();
                //console.log("login done", postLoginCallback);

            });

            loginXHR.fail(function(err) {
                // console.log("login error", err);
                klp.utils.stopSubmit(formID);
                var errors = JSON.parse(err.responseText);
                var $field = $('#loginPassword');
                if (errors.detail || errors.non_field_errors) {
                    klp.utils.invalidateField($field, "Invalid mobile/email/password");
                } else {
                    klp.utils.alertMessage("Login failed due to unknown error. Please contact us if this happens again.", "error");
                }
            });
        }
    }

    function submitForgotPassword(e) {
        if (e) {
            e.preventDefault();
        }
        var formID = 'forgotPasswordForm';

        klp.utils.clearValidationErrors(formID);
        var isValid = klp.utils.validateRequired(formID);
        if (isValid) {
            var data = {
                'mobile_no': $('#forgotPasswordMobile').val()
            };
            var url = 'users/otp-generate/';
            var $xhr = klp.api.do(url, data, 'POST');
            klp.utils.startSubmit(formID);
            $xhr.done(function() {
                klp.utils.stopSubmit(formID);
                showForgotPasswordOTP(null, $('#forgotPasswordMobile').val());
            });
            $xhr.fail(function(err) {
                klp.utils.stopSubmit(formID);
                var errorJSON = JSON.parse(err.responseText);
                if (errorJSON.detail) {
                    klp.utils.invalidateField($('#forgotPasswordMobile'), errorJSON.detail);
                }
            });
        }
    }


    function submitSignupOtp(e) {
        if (e) {
            e.preventDefault();
        }
        var formID = 'signupOtpForm';

        klp.utils.clearValidationErrors(formID);
        var isValid = klp.utils.validateRequired(formID);
        if (isValid) {
            var data = {
                'mobile_no': $('#signupOtpMobile').val(),
                'otp': $('#signupOtp').val()
            };
            var url = 'users/otp-update/';
            var $xhr = klp.api.do(url, data, 'POST');
            klp.utils.startSubmit(formID);
            $xhr.done(function() {
                klp.utils.stopSubmit(formID);
                klp.utils.alertMessage("Your mobile number has been verified successfully. Please proceed to login", "success");
                showLogin(null, "Your mobile number has been verified.<br>Please proceed to login below.");
            });
            $xhr.fail(function(err) {
                klp.utils.stopSubmit(formID);
                var errorJSON = JSON.parse(err.responseText);
                if (errorJSON.detail) {
                    klp.utils.invalidateField($('#signupOtp'), errorJSON.detail);
                } else {
                    klp.utils.alertMessage("We are not able to verify your number do to an unknown error. Please contact us if this happens again.", "error");
                }
            });
        }
    }


    function submitPasswordOtpForm(e) {
        if (e) {
            e.preventDefault();
        }
        var formID = 'forgotPasswordOTPForm';

        klp.utils.clearValidationErrors(formID);
        var isValid = klp.utils.validateRequired(formID);
        if (isValid) {
            var data = {
                'mobile_no': $('#forgotPasswordOtpMobile').val(),
                'otp': $('#forgotPasswordOtp').val(),
                'password': $('#forgotPasswordPassword').val()
            };
            var url = 'users/otp-password-reset/';
            var $xhr = klp.api.do(url, data, 'POST');
            klp.utils.startSubmit(formID);
            $xhr.done(function() {
                klp.utils.stopSubmit(formID);
                klp.utils.alertMessage("Your password has been changed successfully. Please proceed to login", "success");
                showLogin(null, "Your password has been changed.<br>Please proceed to login below.");
            });
            $xhr.fail(function(err) {
                klp.utils.stopSubmit(formID);
                var errorJSON = JSON.parse(err.responseText);
                if (errorJSON.detail) {
                    klp.utils.invalidateField($('#forgotPasswordOtp'), errorJSON.detail);
                } else {
                    klp.utils.alertMessage("We are not able to change your password do to an unknown error. Please contact us if this happens again.", "error");
                }
            });
        }
    }


})();
