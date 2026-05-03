import SwiftUI
import Combine

struct DeviceStatus {
    var networkMode: String = "SA"
    var networkOperator: String = "CMCC"
    var isConnected: Bool = true
    var signalStrength: Int = -44
    var sinr: Double = 28.7
    var band: String = "N41"
    var arfcn: Int = 504990
    var pci: Int = 20
    var bandWidth: String = "100MHz"
    var downloadSpeed: String = "60 B/s"
    var uploadSpeed: String = "431 B/s"
    var batteryLevel: Int = 81
    var batteryTemp: String = "30°C"
    var cpuTemp: String = "33°C"
    var chargingStatus: String = "直供"
    var isPowerConnected: Bool = true
    var connectionUptime: String = "38 分钟"
    var dailyUsage: String = "26.815GB"
    var monthlyUsage: String = "51.831GB"
    var rfFrequency: String = "2524.95MHz"
    var deviceUptime: String = "39 分钟"
    var ipAddress: String = "10.77.23.117"
}

struct WiFiInfo {
    var ssid2G: String = "MAOMAO_5G"
    var is2GEnabled: Bool = false
    var password2G: String = "625568895"
    var ssid5G: String = "MAOMAO_5G"
    var is5GEnabled: Bool = true
    var password5G: String = "625568895"
}

struct ConnectedDevice: Identifiable {
    var id = UUID()
    var index: Int
    var hostname: String
    var macAddress: String
    var ipAddress: String
    var connectionType: String
}

class DeviceManager: ObservableObject {
    static let shared = DeviceManager()
    
    @Published var deviceStatus = DeviceStatus()
    @Published var wifiInfo = WiFiInfo()
    @Published var connectedDevices: [ConnectedDevice] = [
        ConnectedDevice(index: 1, hostname: "DESKTOP-3GNBOVJ", macAddress: "DC:21:48:96:84:BC", ipAddress: "192.168.1.6", connectionType: "Wi-Fi"),
        ConnectedDevice(index: 2, hostname: "vivo-X200", macAddress: "96:03:D2:B8:DC:C9", ipAddress: "192.168.1.92", connectionType: "Wi-Fi"),
        ConnectedDevice(index: 3, hostname: "Unknown", macAddress: "26:62:3E:5C:24:DE", ipAddress: "192.168.1.21", connectionType: "Wi-Fi")
    ]
    @Published var smsMessages: [SMSMessage] = []
    @Published var isConnected = true
    @Published var deviceIP: String = "192.168.1.1"
    
    private init() {
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDeviceStatus()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func connectToDevice(ip: String) {
        deviceIP = ip
        isConnected = true
    }
    
    func updateDeviceStatus() {
        deviceStatus.batteryLevel = max(0, min(100, deviceStatus.batteryLevel + Int.random(in: -1...1)))
        deviceStatus.signalStrength = -40 + Int.random(in: -10...10)
    }
    
    func sendSMS(phoneNumber: String, content: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let newMessage = SMSMessage(
                phoneNumber: phoneNumber,
                content: content,
                date: Date(),
                isRead: true,
                messageType: .outbox
            )
            self.smsMessages.append(newMessage)
            completion(true)
        }
    }
    
    func rebootDevice(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(true)
        }
    }
}

struct SMSMessage: Identifiable {
    var id = UUID()
    var phoneNumber: String
    var content: String
    var date: Date
    var isRead: Bool
    var messageType: MessageType
}

enum MessageType: Int {
    case draft = 0
    case inbox = 1
    case outbox = 2
    case forward = 4
}

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("主页", systemImage: "house.fill")
                }
            
            SMSView()
                .tabItem {
                    Label("短信", systemImage: "message.fill")
                }
            
            NetworkView()
                .tabItem {
                    Label("网络", systemImage: "antenna.radiowaves.left.and.right")
                }
            
            WiFiSettingsView()
                .tabItem {
                    Label("WiFi", systemImage: "wifi")
                }
            
            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
        }
        .tint(.blue)
    }
}

struct HomeView: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var showingAdvanced = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    networkInfoCard
                    signalInfoCard
                    speedInfoCard
                    batteryInfoCard
                    usageInfoCard
                    wifiInfoCard
                    connectedDevicesCard
                }
                .padding()
            }
            .navigationTitle("5G 随身WiFi")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("高级") {
                        showingAdvanced = true
                    }
                }
            }
            .sheet(isPresented: $showingAdvanced) {
                AdvancedMenuView()
            }
        }
    }
    
    private var networkInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("网络信息")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Picker("网络模式", selection: .constant(0)) {
                    Text("自动").tag(0)
                    Text("SA/NSA").tag(1)
                    Text("仅SA").tag(2)
                }
                .pickerStyle(.menu)
                .font(.subheadline)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(deviceManager.deviceStatus.networkOperator) \(deviceManager.deviceStatus.networkMode)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(deviceManager.deviceStatus.isConnected ? "已连接" : "未连接")
                        .font(.subheadline)
                        .foregroundColor(deviceManager.deviceStatus.isConnected ? .green : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Text("频段:")
                            .foregroundColor(.secondary)
                        Text(deviceManager.deviceStatus.band)
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("频点:")
                            .foregroundColor(.secondary)
                        Text("\(deviceManager.deviceStatus.arfcn)")
                            .fontWeight(.medium)
                    }
                    HStack {
                        Text("PCI:")
                            .foregroundColor(.secondary)
                        Text("\(deviceManager.deviceStatus.pci)")
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var signalInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("信号强度")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("RSRP")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(deviceManager.deviceStatus.signalStrength) dBm")
                            .fontWeight(.medium)
                    }
                    ProgressView(value: normalizeSignal(deviceManager.deviceStatus.signalStrength), total: 1)
                        .tint(.green)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("SINR")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f dB", deviceManager.deviceStatus.sinr))
                            .fontWeight(.medium)
                    }
                    ProgressView(value: normalizeSINR(deviceManager.deviceStatus.sinr), total: 1)
                        .tint(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var speedInfoCard: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.green)
                    Text("下载")
                        .foregroundColor(.secondary)
                }
                Text(deviceManager.deviceStatus.downloadSpeed)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Text("上传")
                        .foregroundColor(.secondary)
                    Image(systemName: "arrow.up")
                        .foregroundColor(.blue)
                }
                Text(deviceManager.deviceStatus.uploadSpeed)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var batteryInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("电池与温度")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    batteryIcon
                    Text("\(deviceManager.deviceStatus.batteryLevel)%")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(deviceManager.deviceStatus.chargingStatus)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "thermometer")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    Text(deviceManager.deviceStatus.batteryTemp)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("电池温度")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 8) {
                    Image(systemName: "cpu")
                        .font(.system(size: 32))
                        .foregroundColor(.purple)
                    Text(deviceManager.deviceStatus.cpuTemp)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("CPU温度")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var batteryIcon: some View {
        let level = deviceManager.deviceStatus.batteryLevel
        let color: Color = level > 50 ? .green : level > 20 ? .yellow : .red
        
        return ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.primary, lineWidth: 2)
                .frame(width: 40, height: 20)
            
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: max(2, CGFloat(level) / 100 * 34), height: 14)
                .offset(x: -3)
            
            if deviceManager.deviceStatus.isPowerConnected {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 12))
            }
            
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.primary)
                .frame(width: 3, height: 8)
                .offset(x: 20)
        }
    }
    
    private var usageInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("流量统计")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("清空") {
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 4) {
                    Text("今日已用")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(deviceManager.deviceStatus.dailyUsage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .center, spacing: 4) {
                    Text("本月已用")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(deviceManager.deviceStatus.monthlyUsage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var wifiInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WiFi 信息")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                wifiBandInfo(is5G: false, ssid: deviceManager.wifiInfo.ssid2G,
                            isEnabled: deviceManager.wifiInfo.is2GEnabled)
                
                Divider()
                
                wifiBandInfo(is5G: true, ssid: deviceManager.wifiInfo.ssid5G,
                            isEnabled: deviceManager.wifiInfo.is5GEnabled)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func wifiBandInfo(is5G: Bool, ssid: String, isEnabled: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(is5G ? "WiFi 5GHz" : "WiFi 2.4GHz")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(ssid)
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(isEnabled ? "开启" : "关闭")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isEnabled ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        .foregroundColor(isEnabled ? .green : .red)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
        }
    }
    
    private var connectedDevicesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("连接设备 (\(deviceManager.connectedDevices.count))")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(deviceManager.connectedDevices) { device in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.hostname)
                                .font(.body)
                                .fontWeight(.medium)
                            Text(device.ipAddress)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(device.connectionType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(device.macAddress)
                                .font(.caption2)
                                .foregroundColor(.tertiary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if device.id != deviceManager.connectedDevices.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private func normalizeSignal(_ signal: Int) -> Double {
        return max(0, min(1, Double(signal + 120) / 80))
    }
    
    private func normalizeSINR(_ sinr: Double) -> Double {
        return max(0, min(1, (sinr + 20) / 50))
    }
}

struct AdvancedMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var showingRebootAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("断开网络") {
                    }
                    
                    Button("原生锁频") {
                    }
                    
                    Button("关机/重启") {
                        showingRebootAlert = true
                    }
                }
                
                Section {
                    NavigationLink("网络设置") {
                        Text("网络设置")
                    }
                    
                    NavigationLink("射频参数") {
                        Text("射频参数")
                    }
                }
            }
            .navigationTitle("高级菜单")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .alert("重启设备", isPresented: $showingRebootAlert) {
                Button("取消", role: .cancel) { }
                Button("重启") {
                    deviceManager.rebootDevice { _ in }
                }
            } message: {
                Text("确定要重启设备吗？")
            }
        }
    }
}

struct SMSView: View {
    @State private var selectedTab = 0
    @State private var showingCompose = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("短信类型", selection: $selectedTab) {
                    Text("收件箱").tag(0)
                    Text("发件箱").tag(1)
                    Text("草稿箱").tag(2)
                    Text("短信转发").tag(3)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if selectedTab == 3 {
                    ForwardSettingsView()
                } else {
                    SMSListView(messageType: MessageType(rawValue: selectedTab) ?? .inbox)
                }
            }
            .navigationTitle("短信管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingCompose = true
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
            .sheet(isPresented: $showingCompose) {
                ComposeSMSView()
            }
        }
    }
}

struct SMSListView: View {
    let messageType: MessageType
    
    var body: some View {
        List {
            ContentUnavailableView {
                Label("暂无短信", systemImage: "tray")
            } description: {
                Text("这里显示短信")
            }
        }
        .refreshable {
        }
    }
}

struct ComposeSMSView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var phoneNumber = ""
    @State private var content = ""
    @State private var isSending = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("收件人")
                            .foregroundColor(.secondary)
                        TextField("输入手机号", text: $phoneNumber)
                            .keyboardType(.phonePad)
                    }
                }
                
                Section {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                } footer: {
                    Text("\(content.count)/160")
                        .foregroundColor(content.count > 160 ? .red : .secondary)
                }
            }
            .navigationTitle("新建短信")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("发送") {
                        isSending = true
                        deviceManager.sendSMS(phoneNumber: phoneNumber, content: content) { success in
                            isSending = false
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(phoneNumber.isEmpty || content.isEmpty || isSending)
                }
            }
        }
    }
}

struct ForwardSettingsView: View {
    @State private var isForwardEnabled = false
    @State private var forwardToken = ""
    @State private var forwardChannel = 1
    @State private var channelId = ""
    @State private var forwardLogs = ""
    
    var body: some View {
        Form {
            Section {
                Toggle("开启转发", isOn: $isForwardEnabled)
                
                HStack {
                    Text("转发令牌")
                    TextField("32位数字字母组合", text: $forwardToken)
                        .textInputAutocapitalization(.never)
                }
                
                Picker("转发渠道", selection: $forwardChannel) {
                    Text("微信").tag(1)
                    Text("邮箱").tag(2)
                    Text("webhook").tag(3)
                }
                
                if forwardChannel == 3 {
                    HStack {
                        Text("渠道编码")
                        TextField("仅选择webhook时填写", text: $channelId)
                    }
                }
            } footer: {
                HStack {
                    Image(systemName: "info.circle")
                    Text("获取转发令牌请访问PushPlus官网")
                }
            }
            
            Section {
                Button("保存配置") {
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                
                Button("删除日志") {
                    forwardLogs = ""
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .tint(.red)
            }
            
            Section("转发日志") {
                TextEditor(text: $forwardLogs)
                    .frame(height: 200)
                    .disabled(true)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NetworkView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("移动网络") {
                    NavigationLink("移动连接") {
                        Text("移动连接设置")
                    }
                    
                    NavigationLink("双卡管理") {
                        Text("双卡管理")
                    }
                    
                    NavigationLink("配置管理") {
                        Text("配置管理")
                    }
                    
                    NavigationLink("网络设置") {
                        Text("网络设置")
                    }
                    
                    NavigationLink("射频参数") {
                        Text("射频参数")
                    }
                    
                    NavigationLink("PIN管理") {
                        Text("PIN管理")
                    }
                }
                
                Section("因特网") {
                    NavigationLink("DNS设置") {
                        Text("DNS设置")
                    }
                    
                    NavigationLink("DHCP设置") {
                        Text("DHCP设置")
                    }
                    
                    NavigationLink("VPN设置") {
                        Text("VPN设置")
                    }
                }
            }
            .navigationTitle("网络设置")
        }
    }
}

struct WiFiSettingsView: View {
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var ssid2G = "MAOMAO_5G"
    @State private var password2G = "625568895"
    @State private var is2GEnabled = false
    @State private var ssid5G = "MAOMAO_5G"
    @State private var password5G = "625568895"
    @State private var is5GEnabled = true
    @State private var showPassword2G = false
    @State private var showPassword5G = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("WiFi 2.4GHz") {
                    Toggle("启用 2.4GHz WiFi", isOn: $is2GEnabled)
                    
                    if is2GEnabled {
                        HStack {
                            Text("SSID")
                            TextField("输入SSID", text: $ssid2G)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("密码")
                            if showPassword2G {
                                TextField("输入密码", text: $password2G)
                                    .multilineTextAlignment(.trailing)
                            } else {
                                SecureField("输入密码", text: $password2G)
                                    .multilineTextAlignment(.trailing)
                            }
                            Button(action: {
                                showPassword2G.toggle()
                            }) {
                                Image(systemName: showPassword2G ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Picker("加密方式", selection: .constant(0)) {
                            Text("WPA2-PSK").tag(0)
                            Text("WPA3-SAE").tag(1)
                            Text("不加密").tag(2)
                        }
                        
                        Picker("信道", selection: .constant(0)) {
                            Text("自动").tag(0)
                            ForEach(1...13, id: \.self) { channel in
                                Text("\(channel)").tag(channel)
                            }
                        }
                        
                        Picker("频宽", selection: .constant(0)) {
                            Text("20MHz").tag(0)
                            Text("40MHz").tag(1)
                        }
                    }
                }
                
                Section("WiFi 5GHz") {
                    Toggle("启用 5GHz WiFi", isOn: $is5GEnabled)
                    
                    if is5GEnabled {
                        HStack {
                            Text("SSID")
                            TextField("输入SSID", text: $ssid5G)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("密码")
                            if showPassword5G {
                                TextField("输入密码", text: $password5G)
                                    .multilineTextAlignment(.trailing)
                            } else {
                                SecureField("输入密码", text: $password5G)
                                    .multilineTextAlignment(.trailing)
                            }
                            Button(action: {
                                showPassword5G.toggle()
                            }) {
                                Image(systemName: showPassword5G ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Picker("加密方式", selection: .constant(0)) {
                            Text("WPA2-PSK").tag(0)
                            Text("WPA3-SAE").tag(1)
                            Text("不加密").tag(2)
                        }
                        
                        Picker("信道", selection: .constant(0)) {
                            Text("自动").tag(0)
                            ForEach([36, 40, 44, 48, 52, 56, 60, 64, 149, 153, 157, 161, 165], id: \.self) { channel in
                                Text("\(channel)").tag(channel)
                            }
                        }
                        
                        Picker("频宽", selection: .constant(0)) {
                            Text("20MHz").tag(0)
                            Text("40MHz").tag(1)
                            Text("80MHz").tag(2)
                            Text("160MHz").tag(3)
                        }
                    }
                }
                
                Section {
                    Button("保存设置") {
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("WiFi设置")
            .onAppear {
                ssid2G = deviceManager.wifiInfo.ssid2G
                password2G = deviceManager.wifiInfo.password2G
                is2GEnabled = deviceManager.wifiInfo.is2GEnabled
                ssid5G = deviceManager.wifiInfo.ssid5G
                password5G = deviceManager.wifiInfo.password5G
                is5GEnabled = deviceManager.wifiInfo.is5GEnabled
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var deviceManager: DeviceManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("设备连接") {
                    HStack {
                        Text("设备IP")
                        Spacer()
                        TextField("192.168.1.1", text: $deviceManager.deviceIP)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    
                    Button("连接设备") {
                        deviceManager.connectToDevice(ip: deviceManager.deviceIP)
                    }
                }
                
                Section("系统信息") {
                    NavigationLink("设备信息") {
                        Text("设备信息")
                    }
                    
                    NavigationLink("流量统计") {
                        Text("流量统计")
                    }
                    
                    NavigationLink("系统日志") {
                        Text("系统日志")
                    }
                }
                
                Section("系统管理") {
                    NavigationLink("系统管理") {
                        Text("系统管理")
                    }
                    
                    NavigationLink("备份与恢复") {
                        Text("备份与恢复")
                    }
                    
                    NavigationLink("固件更新") {
                        Text("固件更新")
                    }
                    
                    NavigationLink("重启与恢复") {
                        Text("重启与恢复")
                    }
                }
                
                Section("其他") {
                    NavigationLink("诊断工具") {
                        Text("诊断工具")
                    }
                    
                    NavigationLink("端口转发") {
                        Text("端口转发")
                    }
                    
                    NavigationLink("DMZ设置") {
                        Text("DMZ设置")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DeviceManager.shared)
    }
}
