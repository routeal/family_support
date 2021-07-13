import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


final double LOGIN_WIDGET_WIDTH = 320;
final double CARD_ELEVATION = 20;
final double SUBMIT_BUTTON_HEIGHT = 38;
final double SUBMIT_BUTTON_WIDTH = 140;

typedef SubmitCallback = Future<String?>? Function(
    BuildContext context, String email, String password);
typedef SendResetPasswordCallback = Future<String?>? Function(
    BuildContext context, String email);
typedef SendEmailVerificationCallback = Future<String?>? Function(
    BuildContext context);
typedef ContextCallback = Future<void>? Function(BuildContext context);

class AuthWidget extends StatefulWidget {
  bool? isAuthPage;
  String title;
  String footer;
  String? initialValue;
  SubmitCallback? onLogin;
  SubmitCallback? onSignup;
  SendEmailVerificationCallback? onSendEmailVerification;
  SendResetPasswordCallback? onSendResetPassword;
  ContextCallback? onSubmitCompleted;
  ContextCallback? onClose;

  AuthWidget({
    Key? key,
    required this.title,
    required this.footer,
    this.initialValue,
    this.onLogin,
    this.onSignup,
    this.onSendEmailVerification,
    this.onSendResetPassword,
    this.onSubmitCompleted,
    this.onClose,
    this.isAuthPage,
  }) : super(key: key);

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  Widget? _animatedWidget;

  Widget get header {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: DefaultTextStyle(
          child: Text(
            widget.title,
          ),
          style: TextStyle(
            color: Theme.of(context).canvasColor,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          )),
    );
  }

  Widget get footer {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DefaultTextStyle(
          child: Text(
            widget.footer,
          ),
          style: TextStyle(
            color: Theme.of(context).canvasColor,
            fontSize: 12,
          )),
    );
  }

  void setLogin() {
    setState(() {
      _animatedWidget = _LoginWidget(
        initialValue: widget.initialValue,
        onLogin: widget.onLogin,
        onSignup: widget.onSignup,
        onSubmitCompleted: widget.onSubmitCompleted,
        notifyParent: setForgotPassword,
      );
    });
  }

  void setForgotPassword() {
    setState(() {
      _animatedWidget = _ForgotPasswordWidget(
        initialValue: widget.initialValue,
        onSendResetPassword: onSendResetPassword,
        onSubmitCompleted: widget.onSubmitCompleted,
        notifyParent: setLogin,
      );
    });
  }

  void setPasswordResetSent(String email) {
    setState(() {
      _animatedWidget = _PasswordResetSentWidget(
        email: email,
        onSendResetPassword: widget.onSendResetPassword,
        notifyParent: setLogin,
      );
    });
  }

  void setEmailVerificationSent(String email) {
    setState(() {
      _animatedWidget = _EmailVerificationSentWidget(
        email: email,
        onSendEmailVerification: widget.onSendEmailVerification,
        onClose: widget.onClose,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.isAuthPage ?? true) {
      setLogin();
    } else {
      setEmailVerificationSent(widget.initialValue!);
    }
  }

  // on success, set a new widget
  Future<String?> onSendResetPassword(
      BuildContext context, String email) async {
    String? error = await widget.onSendResetPassword!(context, email);
    if (error == null) {
      setPasswordResetSent(email);
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).primaryColor;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Container(
                color: bgColor,
                child: Center(
                  child: Column(
                    children: [
                      Spacer(),
                      header,
                      // widgets are switched
                      AnimatedSwitcher(
                          duration: const Duration(seconds: 1),
                          transitionBuilder: (Widget child,
                                  Animation<double> animation) =>
                              /*
                              SlideTransition(
                                position: Tween<Offset>(begin: Offset(1.2, 0), end: Offset(0, 0))
                                    .animate(animation),
                                child: child,
                              ),
                          */
                              ScaleTransition(scale: animation, child: child),
                          child: _animatedWidget!),
                      Spacer(),
                      Expanded(
                          child: Container(
                        alignment: Alignment.bottomCenter,
                        child: footer,
                      ))
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmailVerificationSentWidget extends StatefulWidget {
  String email;
  SendEmailVerificationCallback? onSendEmailVerification;
  ContextCallback? onClose;

  _EmailVerificationSentWidget({
    required this.email,
    this.onSendEmailVerification,
    this.onClose,
  });

  @override
  _EmailVerificationSentWidgetState createState() =>
      _EmailVerificationSentWidgetState();
}

class _EmailVerificationSentWidgetState
    extends State<_EmailVerificationSentWidget> with LoginWidgetCommon {
  bool _hasSent = false;

  Widget get title {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      child: DefaultTextStyle(
        child: Text('Please verify your email'),
        style: Theme.of(context).textTheme.headline5!,
      ),
    );
  }

  Widget get body1 {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text('You\'re almost there! We sent an email to'),
    );
  }

  Widget get emailto {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(widget.email),
    );
  }

  Widget get body2 {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
          'Just click on the link in that email to complete your signup.  If you don\'t see it, you may need to check your spam folder'),
    );
  }

  Widget get resend {
    return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 2),
        child: SizedBox(
          width: SUBMIT_BUTTON_WIDTH,
          height: SUBMIT_BUTTON_HEIGHT,
          child: ElevatedButton(
            onPressed: _hasSent ? null : submit,
            child: Text('Resend Email',
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                  fontSize: 16,
                )),
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
          ),
        ));
  }

  Widget get close {
    return Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 0),
        child: DefaultTextStyle(
          child: TextButton(
            child: Text('Back',
                style: TextStyle(
                  fontSize: 16,
                )),
            onPressed: () => widget.onClose!(context),
            style:
                TextButton.styleFrom(primary: Theme.of(context).primaryColor),
          ),
          style: Theme.of(context).textTheme.bodyText1!,
        ));
  }

  Widget get status {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 4),
      child: Text(error!,
          style: TextStyle(
            color: Theme.of(context).errorColor,
            fontSize: 12,
          )),
    );
  }

  void submit() async {
    // start loading icon
    setState(() {
      isSubmitting = true;
    });

    // send email
    error = await widget.onSendEmailVerification!(context);

    // disable the resend button on success
    _hasSent = (error == null);

    // stop loading icon
    setState(() {
      isSubmitting = false;
    });

    if (error == null) {
      error = 'email verification has been sent.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LOGIN_WIDGET_WIDTH,
      child: Card(
        elevation: CARD_ELEVATION,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CARD_ELEVATION),
        ),
        child: new Container(
          //color: Colors.black12,
          padding: EdgeInsets.all(16),
          child: FocusTraversalGroup(
            child: Column(
              children: <Widget>[
                title,
                body1,
                emailto,
                body2,
                isSubmitting ? loadingIcon : resend,
                close,
                if (error != null) status,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordResetSentWidget extends StatefulWidget {
  String email;
  SendResetPasswordCallback? onSendResetPassword;
  VoidCallback notifyParent;

  _PasswordResetSentWidget({
    required this.email,
    this.onSendResetPassword,
    required this.notifyParent,
  });

  @override
  _PasswordResetSentWidgetState createState() =>
      _PasswordResetSentWidgetState();
}

class _PasswordResetSentWidgetState extends State<_PasswordResetSentWidget>
    with LoginWidgetCommon {
  bool _hasSent = false;

  Widget get title {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      child: DefaultTextStyle(
        child: Text('Please verify your email'),
        style: Theme.of(context).textTheme.headline5!,
      ),
    );
  }

  Widget get body1 {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text('We sent a password reset email to'),
    );
  }

  Widget get emailto {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(widget.email),
    );
  }

  Widget get body2 {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
          'If you don\'t see it, you may need to check your spam folder'),
    );
  }

  Widget get resend {
    return Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 2),
        child: SizedBox(
          width: SUBMIT_BUTTON_WIDTH,
          height: SUBMIT_BUTTON_HEIGHT,
          child: ElevatedButton(
            onPressed: _hasSent ? null : submit,
            child: Text('Resend Email',
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                  fontSize: 16,
                )),
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
          ),
        ));
  }

  Widget get close {
    return Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 0),
        child: DefaultTextStyle(
          child: TextButton(
            child: Text('BACK',
                style: TextStyle(
                  fontSize: 16,
                )),
            onPressed: widget.notifyParent,
            style:
                TextButton.styleFrom(primary: Theme.of(context).primaryColor),
          ),
          style: Theme.of(context).textTheme.bodyText1!,
        ));
  }

  Widget get status {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 4),
      child: Text(error!,
          style: TextStyle(
            color: Theme.of(context).errorColor,
            fontSize: 12,
          )),
    );
  }

  void submit() async {
    // start loading icon
    setState(() {
      isSubmitting = true;
    });

    // send email
    error = await widget.onSendResetPassword!(context, widget.email);

    // disable the resend button on success
    _hasSent = (error == null);

    // stop loading icon
    setState(() {
      isSubmitting = false;
    });

    if (error == null) {
      error = 'email verification has been sent.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LOGIN_WIDGET_WIDTH,
      child: Card(
        elevation: CARD_ELEVATION,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CARD_ELEVATION),
        ),
        child: new Container(
          //color: Colors.black12,
          padding: EdgeInsets.all(16),
          child: FocusTraversalGroup(
            child: Column(
              children: <Widget>[
                title,
                body1,
                emailto,
                body2,
                isSubmitting ? loadingIcon : resend,
                close,
                if (error != null) status,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordWidget extends StatefulWidget {
  String? initialValue;
  SendResetPasswordCallback? onSendResetPassword;
  ContextCallback? onSubmitCompleted;
  VoidCallback notifyParent;

  _ForgotPasswordWidget({
    this.initialValue,
    required this.onSendResetPassword,
    this.onSubmitCompleted,
    required this.notifyParent,
  });

  @override
  _ForgotPasswordWidgetState createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<_ForgotPasswordWidget>
    with LoginWidgetCommon {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  String? _emailText;

  Widget get forgotPassword {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 8),
      child: DefaultTextStyle(
        child: Text('Forgot Password?'),
        style: Theme.of(context).textTheme.headline6!,
      ),
    );
  }

  Widget get email {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: TextFormField(
        style: TextStyle(
          fontSize: 14,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          prefixIcon: Icon(Icons.account_circle_rounded),
          labelText: AppLocalizations.of(context)!.email,
        ),
        onChanged: null,
        onSaved: (String? value) => _emailText = value,
        validator: (String? value) {
          return isValidEmail(value) ? null : 'Enter valid Email';
        },
      ),
    );
  }

  Widget get description {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16, left: 16, right: 16),
      child: DefaultTextStyle(
        child: Text('We will send you instructions to reset passwords.'),
        style: Theme.of(context).textTheme.bodyText1!,
      ),
    );
  }

  Widget get recover {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: SizedBox(
          width: SUBMIT_BUTTON_WIDTH,
          height: SUBMIT_BUTTON_HEIGHT,
          child: ElevatedButton(
            onPressed: submit,
            child: Text('RECOVER',
                style: TextStyle(
                  color: Theme.of(context).canvasColor,
                  fontSize: 16,
                )),
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
          ),
        ));
  }

  Widget get goback {
    return Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 4),
        child: DefaultTextStyle(
          child: TextButton(
            child: Text('GO BACK',
                style: TextStyle(
                  fontSize: 16,
                )),
            onPressed: widget.notifyParent,
            style:
                TextButton.styleFrom(primary: Theme.of(context).primaryColor),
          ),
          style: Theme.of(context).textTheme.bodyText1!,
        ));
  }

  Widget get status {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 4),
      child: Text(error!,
          style: TextStyle(
            color: Theme.of(context).errorColor,
            fontSize: 12,
          )),
    );
  }

  bool validateAndSave() {
    bool hasValidated = _formKey.currentState?.validate() ?? false;
    if (hasValidated) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  void submit() async {
    if (isSubmitting) return;

    if (!validateAndSave()) return;

    // start loading icon
    setState(() {
      isSubmitting = true;
    });

    // send email
    error = await widget.onSendResetPassword!(context, _emailText!);

    // stop loading icon
    setState(() {
      isSubmitting = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LOGIN_WIDGET_WIDTH,
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: new Container(
          //color: Colors.black12,
          padding: EdgeInsets.all(16),
          child: FocusTraversalGroup(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  forgotPassword,
                  email,
                  description,
                  isSubmitting ? loadingIcon : recover,
                  goback,
                  if (error != null) status,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }
}

class _LoginWidget extends StatefulWidget {
  String? initialValue;
  SubmitCallback? onLogin;
  SubmitCallback? onSignup;
  ContextCallback? onSubmitCompleted;
  final Function() notifyParent;

  _LoginWidget({
    this.initialValue,
    required this.onLogin,
    required this.onSignup,
    this.onSubmitCompleted,
    required this.notifyParent,
  });

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<_LoginWidget> with LoginWidgetCommon {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _passwd = TextEditingController();
  final _confirm = TextEditingController();

  bool _isObscured = true;
  bool _isLogin = true;
  bool _passwdNotMatch = false;

  String? _emailText;
  String? _passwdText;
  String? _confirmText;

  Widget get email {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: TextFormField(
        style: TextStyle(
          fontSize: 14,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          prefixIcon: Icon(Icons.account_circle_rounded),
          labelText: AppLocalizations.of(context)!.email,
        ),
        onChanged: null,
        onSaved: (String? value) => _emailText = value,
        validator: (String? value) {
          return isValidEmail(value) ? null : 'Enter valid Email';
        },
      ),
    );
  }

  Widget get password {
    return Padding(
      padding: EdgeInsets.only(top: 8, bottom: 8),
      child: TextFormField(
        style: TextStyle(
          fontSize: 14,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: _isObscured,
        controller: _passwd,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            prefixIcon: Icon(Icons.lock),
            suffixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.0),
                child: GestureDetector(
                  child: _isObscured
                      ? Icon(Icons.visibility_rounded)
                      : Icon(Icons.visibility_off_rounded),
                  onTap: toggleObscured,
                )),
            labelText: AppLocalizations.of(context)!.password),
        onChanged: (_) {
          if (_passwdNotMatch) {
            _passwdNotMatch = false;
            setState(() {});
          }
        },
        onSaved: (String? value) => _passwdText = value,
        validator: (String? value) {
          if (value?.isEmpty ?? true) return "Enter password";
          if (value!.length < 6) return "Must be more than 6 characters";
          return null;
        },
      ),
    );
  }

  Widget get confirm {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: TextFormField(
        style: TextStyle(
          fontSize: 14,
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        obscureText: _isObscured,
        controller: _confirm,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            prefixIcon: Icon(Icons.lock),
            suffixIcon: Padding(
                padding: EdgeInsetsDirectional.only(end: 12.0),
                child: GestureDetector(
                  child: _isObscured
                      ? Icon(Icons.visibility_rounded)
                      : Icon(Icons.visibility_off_rounded),
                  onTap: toggleObscured,
                )),
            labelText: 'Confirm'),
        onChanged: (_) {
          if (_passwdNotMatch) {
            _passwdNotMatch = false;
            setState(() {});
          }
        },
        onSaved: (String? value) => _confirmText = value,
        validator: (String? value) {
          if (_passwdNotMatch) return "Passwords do not match";
          if (value?.isEmpty ?? true) return "Enter confirm";
          if (value!.length < 6) return "Must be more than 6 characters";
          return null;
        },
      ),
    );
  }

  Widget get forgotPassword {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 4),
      child: DefaultTextStyle(
        child: TextButton(
          child: Text('Forgot Password?'),
          onPressed: widget.notifyParent,
          style: TextButton.styleFrom(
            primary: Colors.black87,
          ),
        ),
        style: Theme.of(context).textTheme.bodyText1!,
      ),
    );
  }

  Widget submit(bool isCurrent, String label, VoidCallback? callback) {
    if (isCurrent) {
      return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: SizedBox(
            width: SUBMIT_BUTTON_WIDTH,
            height: SUBMIT_BUTTON_HEIGHT,
            child: ElevatedButton(
              onPressed: callback,
              child: Text(label,
                  style: TextStyle(
                    color: Theme.of(context).canvasColor,
                    fontSize: 16,
                  )),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ))),
            ),
          ));
    } else {
      return Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 4),
          child: DefaultTextStyle(
            child: TextButton(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 16,
                  )),
              onPressed: callback,
              style:
                  TextButton.styleFrom(primary: Theme.of(context).primaryColor),
            ),
            style: Theme.of(context).textTheme.bodyText1!,
          ));
    }
  }

  Widget get status {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 4),
      child: Text(error!,
          style: TextStyle(
            color: Theme.of(context).errorColor,
            fontSize: 12,
          )),
    );
  }

  void toggleObscured() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  void toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      error = null;
    });
  }

  bool validateAndSave() {
    bool hasValidated = _formKey.currentState?.validate() ?? false;
    if (hasValidated) {
      _formKey.currentState?.save();
      return true;
    }
    return false;
  }

  void exec(SubmitCallback callback) async {
    error = null;

    // start loading icon
    setState(() {
      isSubmitting = true;
    });

    // run either login or signup
    error = await callback(context, _emailText!, _passwdText!);

    if (error == null) {
      return;
    }

    // stop loading icon
    setState(() {
      isSubmitting = false;
    });

    // notify the completion
    if (widget.onSubmitCompleted != null) widget.onSubmitCompleted!(context);
  }

  void login() {
    if (isSubmitting) return;
    if (!validateAndSave()) return;
    exec(widget.onLogin!);
  }

  void signup() {
    if (isSubmitting) return;
    if (!validateAndSave()) return;
    if (_passwdText != _confirmText) {
      _passwdNotMatch = true;
      setState(() {});
      return;
    }
    exec(widget.onSignup!);
  }

  @override
  void initState() {
    super.initState();
    _email.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LOGIN_WIDGET_WIDTH,
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: new Container(
          //color: Colors.black12,
          padding: EdgeInsets.all(16),
          child: FocusTraversalGroup(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  email,
                  password,
                  _isLogin ? Container() : confirm,
                  _isLogin ? forgotPassword : Container(),
                  isSubmitting
                      ? loadingIcon
                      : (_isLogin
                          ? submit(true, AppLocalizations.of(context)!.login, login)
                          : submit(true, AppLocalizations.of(context)!.signup, signup)),
                  _isLogin
                      ? submit(false, AppLocalizations.of(context)!.signup, toggleMode)
                      : submit(false, AppLocalizations.of(context)!.login, toggleMode),
                  if (error != null) status,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _passwd.dispose();
    _confirm.dispose();
    super.dispose();
  }
}

class LoginWidgetCommon {
  bool _isSubmitting = false;
  String? _error;

  void set isSubmitting(bool b) => _isSubmitting = b;
  bool get isSubmitting => _isSubmitting;

  void set error(String? e) => _error = e;
  String? get error => _error;

  Widget get loadingIcon {
    return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 2),
        child: SizedBox(
            width: SUBMIT_BUTTON_HEIGHT,
            height: SUBMIT_BUTTON_HEIGHT,
            child: CircularProgressIndicator()));
  }

  bool isValidEmail(String? str) {
    if (str == null) return false;
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(str);
  }
}
