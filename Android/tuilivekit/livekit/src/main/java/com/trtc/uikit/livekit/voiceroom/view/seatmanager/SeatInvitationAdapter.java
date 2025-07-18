package com.trtc.uikit.livekit.voiceroom.view.seatmanager;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.utils.widget.ImageFilterView;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.engine.room.TUIRoomDefine;
import com.trtc.tuikit.common.imageloader.ImageLoader;
import com.trtc.uikit.livekit.R;
import com.trtc.uikit.livekit.voiceroom.manager.VoiceRoomManager;
import com.trtc.uikit.livekit.voiceroom.state.SeatState;
import com.trtc.uikit.livekit.voiceroom.state.UserState;

import java.util.Collection;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class SeatInvitationAdapter extends RecyclerView.Adapter<SeatInvitationAdapter.ViewHolder> {

    private final Context                                      mContext;
    private final VoiceRoomManager                             mVoiceRoomManager;
    private final SeatState                                    mSeatState;
    private       OnInviteButtonClickListener                  mOnInviteButtonClickListener;
    private final CopyOnWriteArrayList<TUIRoomDefine.UserInfo> mData = new CopyOnWriteArrayList<>();

    public SeatInvitationAdapter(Context context, VoiceRoomManager liveController) {
        mVoiceRoomManager = liveController;
        mContext = context;
        mSeatState = liveController.getSeatState();
        initData();
    }

    private void initData() {
        mData.clear();
        Collection<TUIRoomDefine.UserInfo> audienceList = mVoiceRoomManager.getUserState().userList.getValue().values();
        List<SeatState.SeatInfo> seatList = mSeatState.seatList.getValue();
        for (TUIRoomDefine.UserInfo userInfo : audienceList) {
            if (seatList.contains(new SeatState.SeatInfo(userInfo.userId))) {
                continue;
            }
            mData.add(userInfo);
        }
    }

    public void setOnInviteButtonClickListener(OnInviteButtonClickListener listener) {
        mOnInviteButtonClickListener = listener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.livekit_voiceroom_item_invite_audience,
                parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        TUIRoomDefine.UserInfo userInfo = mData.get(position);
        if (TextUtils.isEmpty(userInfo.avatarUrl)) {
            holder.imageHead.setImageResource(R.drawable.livekit_ic_avatar);
        } else {
            ImageLoader.load(mContext, holder.imageHead, userInfo.avatarUrl, R.drawable.livekit_ic_avatar);
        }

        if (TextUtils.isEmpty(userInfo.userName)) {
            holder.textName.setText(userInfo.userId);
        } else {
            holder.textName.setText(userInfo.userName);
        }
        if (mSeatState.sentSeatInvitationMap.getValue().containsKey(userInfo.userId)) {
            holder.inviteButton.setSelected(true);
            holder.inviteButton.setText(R.string.common_cancel);
            holder.inviteButton.setTextColor(mContext.getResources().getColor(R.color.common_not_standard_red));
        } else {
            holder.inviteButton.setSelected(false);
            holder.inviteButton.setText(R.string.common_voiceroom_invite);
            holder.inviteButton.setTextColor(Color.WHITE);
        }
        holder.inviteButton.setOnClickListener(v -> {
            if (mOnInviteButtonClickListener != null) {
                mOnInviteButtonClickListener.onItemClick(holder.inviteButton, userInfo);
            }
        });
    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    @SuppressLint("NotifyDataSetChanged")
    public void updateData() {
        initData();
        notifyDataSetChanged();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        public ImageFilterView imageHead;
        public TextView        textName;
        public TextView        textLevel;
        public TextView        inviteButton;

        public ViewHolder(View itemView) {
            super(itemView);
            imageHead = itemView.findViewById(R.id.iv_head);
            textName = itemView.findViewById(R.id.tv_name);
            textLevel = itemView.findViewById(R.id.tv_level);
            inviteButton = itemView.findViewById(R.id.invite_button);
        }
    }

    public interface OnInviteButtonClickListener {
        void onItemClick(TextView inviteButton, TUIRoomDefine.UserInfo userInfo);
    }
}
