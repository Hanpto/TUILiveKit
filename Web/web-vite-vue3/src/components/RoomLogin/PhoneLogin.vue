<template>
  <div class="phone-login">
    <input
      v-model="phoneNumber"
      :class="[isMobile ? 'input-mobile' : 'input']"
      :placeholder="t('Mobile number')" auto-complete="true"
      enterkeyhint="complete"
    >
    <div class="area-container">
      <svg-icon :icon="PhoneIcon"></svg-icon>
    </div>
  </div>
</template>

<script setup lang="ts">
import { SvgIcon } from '@tencentcloud/livekit-web-vue3';
import { isMobile }  from '@tencentcloud/livekit-web-vue3/es/utils/environment';
import PhoneIcon from '../icons/PhoneIcon.vue';
import { ref, watch } from 'vue';
import { useI18n } from '../../locales';

const { t } = useI18n();
const emit = defineEmits(['update-phone-number']);
const phoneNumber = ref('');
watch(() => phoneNumber.value, (val) => {
  phoneNumber.value = val.replace(/\D/g, '');
  emit('update-phone-number', phoneNumber.value);
});
</script>

<style lang="scss" scoped>
.phone-login{
  position:relative;
  width:100%;
  height:100%;
  .input{
    -webkit-appearance:none;
    background-color:#292D38;
    background-image:none;
    border-radius:8px;
    border:1px solid #292D38;
    box-sizing:border-box;
    color: #B3B8C8;
    display:inline-block;
    font-size:inherit;
    height:60px;
    line-height:60px;
    outline:none;
    padding:0 15px 0 40px;
    transition:border-color .2s cubic-bezier(.645,.045,.355,1);
    width:100%;
  }
  .input-mobile{
    -webkit-appearance:none;
    background-color:rgba(207, 213, 230, 0.2);
    background-image:none;
    border-radius:8px;
    box-sizing:border-box;
    color: #B3B8C8;
    display:inline-block;
    font-size:inherit;
    height:60px;
    line-height:60px;
    outline:none;
    border: 0px;
    padding:0 15px 0 40px;
    transition:border-color .2s cubic-bezier(.645,.045,.355,1);
    width:100%;
    }
  .area-container{
    width:20px;
    height:20px;
    // border: 1px solid pink;
    position:absolute;
    top:32%;
    left:4%;
  }
  .verify-code{
    margin-top:30px;
  }
}
</style>
