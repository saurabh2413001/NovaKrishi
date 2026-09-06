import twilio from 'twilio';
function config() {
    return {
        accountSid: process.env.TWILIO_ACCOUNT_SID,
        authToken: process.env.TWILIO_AUTH_TOKEN,
        serviceSid: process.env.TWILIO_VERIFY_SERVICE_SID,
        enabled: process.env.TWILIO_VERIFY_ENABLED?.toLowerCase() === 'true'
    };
}
function toE164Indian(rawPhone) {
    const digits = (rawPhone || '').replace(/\D/g, '');
    if (digits.length === 10)
        return `+91${digits}`;
    if (digits.length === 12 && digits.startsWith('91'))
        return `+${digits}`;
    return null;
}
export const smsService = {
    isVerifyEnabled() {
        const c = config();
        return c.enabled && !!c.accountSid && !!c.authToken && !!c.serviceSid;
    },
    async sendVerification(phoneNumber) {
        const c = config();
        const to = toE164Indian(phoneNumber);
        if (!to || !this.isVerifyEnabled())
            return false;
        try {
            const client = twilio(c.accountSid, c.authToken);
            await client.verify.v2.services(c.serviceSid).verifications.create({
                to,
                channel: 'sms'
            });
            console.log(`[smsService] Verification SMS requested for ${to}`);
            return true;
        }
        catch (error) {
            console.error('[smsService] Twilio Verify send failed:', error?.message || error);
            return false;
        }
    },
    async checkVerification(phoneNumber, code) {
        const c = config();
        const to = toE164Indian(phoneNumber);
        if (!to || !this.isVerifyEnabled())
            return false;
        try {
            const client = twilio(c.accountSid, c.authToken);
            const result = await client.verify.v2.services(c.serviceSid).verificationChecks.create({
                to,
                code
            });
            return result.status === 'approved';
        }
        catch (error) {
            console.error('[smsService] Twilio Verify check failed:', error?.message || error);
            return false;
        }
    },
    async sendOtpSms(phoneNumber, otp) {
        // Legacy helper retained for compatibility. Production OTP uses Verify above.
        if (this.isVerifyEnabled())
            return this.sendVerification(phoneNumber);
        console.log(`[DEV OTP] ${phoneNumber}: ${otp}`);
        return true;
    }
};
