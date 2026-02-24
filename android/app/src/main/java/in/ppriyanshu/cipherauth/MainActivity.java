package in.ppriyanshu.cipherauth;

import android.os.Build;
import android.view.WindowManager;
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    protected void onResume() {
        super.onResume();
        enableSecureWindow();
    }
    private void enableSecureWindow() {
        getWindow().setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        );
    }
}
