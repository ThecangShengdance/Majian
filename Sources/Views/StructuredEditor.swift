import SwiftUI

struct StructuredEditorView: View {
    @ObservedObject var model: MajianModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            protocolGrid

            Rectangle()
                .fill(Palette.line.opacity(0.65))
                .frame(height: 1)

            HStack(spacing: 8) {
                ProtocolTag(text: model.draft.structured.kind.prefix)
                Text(model.draft.structured.kind.helper)
                    .font(MajianFont.body(10))
                    .foregroundStyle(Palette.muted)
                    .lineLimit(1)
                Spacer(minLength: 6)
                Button {
                    model.loadSample()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 8.5))
                        Text("填入示例")
                            .font(MajianFont.body(9.5, weight: .medium))
                    }
                    .foregroundStyle(Palette.teal)
                    .padding(.horizontal, 8)
                    .frame(height: 23)
                    .background(
                        Capsule()
                            .fill(Palette.teal.opacity(0.07))
                    )
                }
                .buttonStyle(.plain)
            }

            form

            feedback
        }
    }

    private var protocolGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 100), spacing: 7)],
            spacing: 7
        ) {
            ForEach(StructuredKind.allCases) { kind in
                ProtocolCard(
                    kind: kind,
                    selected: model.draft.structured.kind == kind
                ) {
                    model.selectStructured(kind)
                }
            }
        }
    }

    @ViewBuilder
    private var form: some View {
        switch model.draft.structured.kind {
        case .phone:
            phoneForm
        case .email:
            emailForm
        case .sms:
            smsForm
        case .wifi:
            wifiForm
        case .location:
            locationForm
        case .contact:
            contactForm
        case .bitcoin:
            bitcoinForm
        }
    }

    // MARK: Phone

    private var phoneForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            MajianTextField(
                title: "电话号码",
                placeholder: "+86 138 0013 8000",
                text: $model.draft.structured.phone,
                icon: "phone",
                mono: true
            )
            Text("生成 tel: 协议。空格、括号与连字符会被移除，+ 与 *、# 会保留。")
                .font(MajianFont.body(10))
                .foregroundStyle(Palette.muted)
        }
    }

    // MARK: Email

    private var emailForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            MajianTextField(
                title: "收件人",
                placeholder: "hello@example.com",
                text: $model.draft.structured.email,
                icon: "envelope"
            )
            MajianTextField(
                title: "主题（可选）",
                placeholder: "来自码笺的问候",
                text: $model.draft.structured.emailSubject,
                icon: "textformat"
            )
            MajianTextArea(
                title: "正文（可选）",
                placeholder: "扫码后自动填入邮件正文…",
                text: $model.draft.structured.emailBody,
                minHeight: 74
            )
        }
    }

    // MARK: SMS

    private var smsForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            MajianTextField(
                title: "接收号码",
                placeholder: "13800000000",
                text: $model.draft.structured.smsNumber,
                icon: "message",
                mono: true
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("协议格式")
                    .font(MajianFont.body(11, weight: .medium))
                    .foregroundStyle(Palette.muted)
                HStack(spacing: 7) {
                    ForEach(SMSStyle.allCases) { style in
                        ChoicePill(
                            title: style.title,
                            selected: model.draft.structured.smsStyle == style
                        ) {
                            model.draft.structured.smsStyle = style
                        }
                    }
                }
            }

            MajianTextArea(
                title: "短信内容（可选）",
                placeholder: "扫码后自动填入短信内容…",
                text: $model.draft.structured.smsMessage,
                minHeight: 70
            )
        }
    }

    // MARK: Wi-Fi

    private var wifiForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            MajianTextField(
                title: "网络名称 SSID",
                placeholder: "码笺工作室",
                text: $model.draft.structured.wifiSSID,
                icon: "wifi"
            )

            MajianTextField(
                title: "密码",
                placeholder: "至少 8 位",
                text: $model.draft.structured.wifiPassword,
                icon: "key",
                isSecure: true
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("加密方式")
                    .font(MajianFont.body(11, weight: .medium))
                    .foregroundStyle(Palette.muted)
                HStack(spacing: 7) {
                    ForEach(WifiSecurity.allCases) { security in
                        ChoicePill(
                            title: security.title,
                            selected: model.draft.structured.wifiSecurity == security
                        ) {
                            model.draft.structured.wifiSecurity = security
                        }
                    }
                }
            }

            MajianToggleRow(
                title: "隐藏网络",
                detail: "SSID 不广播时打开",
                isOn: $model.draft.structured.wifiHidden
            )

            Text("生成标准 WIFI: 协议。密码只写入二维码，不会发送到网络。")
                .font(MajianFont.body(10))
                .foregroundStyle(Palette.muted)
        }
    }

    // MARK: Location

    private var locationForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "纬度 Latitude",
                    placeholder: "31.230416",
                    text: $model.draft.structured.latitude,
                    icon: "location",
                    mono: true
                )
                MajianTextField(
                    title: "经度 Longitude",
                    placeholder: "121.473701",
                    text: $model.draft.structured.longitude,
                    icon: "location",
                    mono: true
                )
            }

            MajianTextField(
                title: "地点名称（可选）",
                placeholder: "上海 · 外滩",
                text: $model.draft.structured.geoLabel,
                icon: "mappin.and.ellipse"
            )

            HStack(spacing: 8) {
                ExampleChip(title: "使用外滩坐标") {
                    model.draft.structured.latitude = "31.230416"
                    model.draft.structured.longitude = "121.473701"
                    model.draft.structured.geoLabel = "上海 · 外滩"
                }
                Spacer()
                Text("范围：纬度 ±90°，经度 ±180°")
                    .font(MajianFont.body(9.5))
                    .foregroundStyle(Palette.muted)
            }
        }
    }

    // MARK: Contact

    private var contactForm: some View {
        VStack(alignment: .leading, spacing: 13) {
            formSection("基本信息")

            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "姓名 *",
                    placeholder: "张三",
                    text: $model.draft.structured.fullName,
                    icon: "person"
                )
                MajianTextField(
                    title: "单位",
                    placeholder: "码笺工作室",
                    text: $model.draft.structured.organization,
                    icon: "building.2"
                )
            }

            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "职位",
                    placeholder: "独立开发者",
                    text: $model.draft.structured.jobTitle,
                    icon: "briefcase"
                )
                MajianTextField(
                    title: "电话",
                    placeholder: "13800000000",
                    text: $model.draft.structured.contactPhone,
                    icon: "phone",
                    mono: true
                )
            }

            formSection("联系方式")

            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "邮箱",
                    placeholder: "hello@example.com",
                    text: $model.draft.structured.contactEmail,
                    icon: "envelope"
                )
                MajianTextField(
                    title: "网站",
                    placeholder: "majian.app",
                    text: $model.draft.structured.website,
                    icon: "globe"
                )
            }

            formSection("地址")

            MajianTextField(
                title: "街道",
                placeholder: "中山东一路",
                text: $model.draft.structured.street,
                icon: "map"
            )

            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "城市",
                    placeholder: "上海",
                    text: $model.draft.structured.city
                )
                MajianTextField(
                    title: "邮编",
                    placeholder: "200002",
                    text: $model.draft.structured.postalCode,
                    mono: true
                )
            }

            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "国家 / 地区",
                    placeholder: "中国",
                    text: $model.draft.structured.country
                )
                Color.clear.frame(height: 1)
            }

            MajianTextArea(
                title: "备注（可选）",
                placeholder: "一句想让对方记住的话…",
                text: $model.draft.structured.contactNote,
                minHeight: 62
            )
        }
    }

    // MARK: Bitcoin

    private var bitcoinForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            MajianTextField(
                title: "比特币地址",
                placeholder: "bc1q… / 1… / 3…",
                text: $model.draft.structured.bitcoinAddress,
                icon: "bitcoinsign.circle",
                mono: true
            )

            HStack(alignment: .top, spacing: 10) {
                MajianTextField(
                    title: "金额 BTC（可选）",
                    placeholder: "0.001",
                    text: $model.draft.structured.bitcoinAmount,
                    mono: true
                )
                MajianTextField(
                    title: "标签（可选）",
                    placeholder: "码笺",
                    text: $model.draft.structured.bitcoinLabel
                )
            }

            MajianTextField(
                title: "附言（可选）",
                placeholder: "感谢支持",
                text: $model.draft.structured.bitcoinMessage,
                icon: "text.bubble"
            )

            NoticeBanner(
                kind: .warning,
                message: "转账前请再次核对地址与金额。二维码本身无法验证地址归属，也无法发起或撤销转账。"
            )
        }
    }

    // MARK: Feedback

    @ViewBuilder
    private var feedback: some View {
        if let error = model.payload.error {
            NoticeBanner(kind: .error, title: "还差一点", message: error)
        } else if let warning = model.payload.warning {
            NoticeBanner(kind: .warning, title: "请留意", message: warning)
        } else if let note = model.payload.note {
            NoticeBanner(kind: .info, message: note)
        }
    }

    private func formSection(_ title: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(MajianFont.body(10, weight: .semibold))
                .foregroundStyle(Palette.ink.opacity(0.72))
            Rectangle()
                .fill(Palette.line.opacity(0.8))
                .frame(height: 1)
        }
    }
}

private struct ProtocolCard: View {
    let kind: StructuredKind
    let selected: Bool
    let action: () -> Void

    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: kind.symbol)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(selected ? Palette.coral : Palette.muted)
                    .frame(width: 15)

                VStack(alignment: .leading, spacing: 1) {
                    Text(kind.title)
                        .font(MajianFont.body(11, weight: selected ? .semibold : .medium))
                        .foregroundStyle(selected ? Palette.card : Palette.ink)
                    Text(kind.prefix)
                        .font(MajianFont.mono(7.5))
                        .foregroundStyle(
                            selected
                                ? Palette.card.opacity(0.5)
                                : Palette.muted.opacity(0.65)
                        )
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .frame(height: 42)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        selected
                            ? Palette.ink
                            : (hovered ? Palette.paperDeep.opacity(0.7) : Palette.paper.opacity(0.4))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(
                        selected ? Color.clear : Palette.line.opacity(0.9),
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
