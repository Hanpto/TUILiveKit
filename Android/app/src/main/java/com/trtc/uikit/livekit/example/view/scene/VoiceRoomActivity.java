package com.trtc.uikit.livekit.example.view.scene;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.tencent.qcloud.tuicore.TUILogin;
import com.trtc.tuikit.common.util.ActivityLauncher;
import com.trtc.uikit.livekit.common.LiveIdentityGenerator;
import com.trtc.uikit.livekit.component.roomlist.TUILiveListFragment;
import com.trtc.uikit.livekit.example.BaseActivity;
import com.trtc.uikit.livekit.example.R;
import com.trtc.uikit.livekit.example.store.AppStore;
import com.trtc.uikit.livekit.voiceroom.VoiceRoomDefine;
import com.trtc.uikit.livekit.voiceroom.VoiceRoomKit;

public class VoiceRoomActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.app_activity_voice_room);

        initWebsiteLinkView();
        initLiveListFragment();
        initCreateRoomView();
        initBackButton();
    }

    private void initWebsiteLinkView() {
        findViewById(R.id.btn_multi_function).setOnClickListener(v -> {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse(AppStore.TRTC_VOICE_ROOM_DOCUMENT_URL));
            ActivityLauncher.startActivity(VoiceRoomActivity.this, intent);
        });
    }

    private void initCreateRoomView() {
        findViewById(R.id.iv_start).setOnClickListener(view -> {
            LiveIdentityGenerator identityGenerator = LiveIdentityGenerator.getInstance();
            String roomId = identityGenerator.generateId(TUILogin.getUserId(), LiveIdentityGenerator.RoomType.VOICE);
            VoiceRoomDefine.CreateRoomParams voiceRoomInfo = new VoiceRoomDefine.CreateRoomParams();
            voiceRoomInfo.maxAnchorCount = VoiceRoomDefine.MAX_CONNECTED_VIEWERS_COUNT;
            VoiceRoomKit.createInstance(getApplicationContext()).createRoom(roomId, voiceRoomInfo);
        });
    }

    private void initBackButton() {
        findViewById(R.id.iv_back).setOnClickListener(v -> finish());
    }

    private void initLiveListFragment() {
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.replace(R.id.fl_live_list, new TUILiveListFragment());
        transaction.commit();
    }
}