//
//  BluetoothViewController.m
//  EShowIOS
//
//  Created by 王迎军 on 16/8/17.
//  Copyright © 2016年 王迎军. All rights reserved.
//

#import "BluetoothViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "BabyBluetooth.h"
#import "BluetoothView.h"
#import "SVProgressHUD.h"
#define channelOnPeropheralView @"peripheralView"
static  CBPeripheral *ConnectedPeripheral;
static  NSDictionary *ConnectedAD;
@interface BluetoothViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CBCentralManagerDelegate>
{
    NSMutableArray *peripherals;
    NSMutableArray *peripheralsAD;
    NSInteger isSelectNumber;  //元素点击时的位置
    BabyBluetooth *baby;
    BOOL isselect;      //蓝牙按钮是否被点击
    BOOL blueToothOpen; //蓝牙是否开启
}
@property (strong, nonatomic) UITextField *device_Name;   //设备名称前缀
@property (strong, nonatomic) UITextField *device_PIN;    //设备PIN码
@property (strong, nonatomic) UIButton *connectBtn;       //蓝牙搜索按钮
@property (strong, nonatomic) UILabel *connectResult;     //搜索状态
@property (strong, nonatomic) NSIndexPath *lastPath;
@property (strong, nonatomic) UISwitch *mySwitch;
@property (strong, nonatomic) CBPeripheral *currPeripheral;  //设备
@property (strong, nonatomic) CBCentralManager *centralManage;  //获取当前蓝牙的状态
@property (strong, nonatomic) NSDictionary *bluetoothAD;
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;

@end

@implementation BluetoothViewController
@synthesize lastPath ;
- (void)initView
{
    isselect = YES;
    _device_Name = [UITextField new];
    _device_Name.delegate = self;
    _device_PIN = [UITextField new];
    _device_PIN.delegate = self;
    _connectBtn =  [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2.0-53, 97, 106, 106)];
    _connectBtn.backgroundColor = RGBColor(236, 236, 239);
    [_connectBtn setTitle:@"一键连接" forState:UIControlStateNormal];
    [_connectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_connectBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    _connectBtn.layer.cornerRadius = 53.0;
    _connectResult = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, ScreenWidth, 30)];
    _connectResult.backgroundColor = [UIColor clearColor];
    _connectResult.font = [UIFont systemFontOfSize:14];
    _connectResult.text = @"搜索附进的蓝牙设备";
    _connectResult.textAlignment = NSTextAlignmentCenter;
    _connectResult.textColor = [UIColor whiteColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"一键搜索";
    self.view.backgroundColor = RGBColor(242, 245, 233);
    [self initView];
    self.centralManage = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    //初始化其他数据 init other
    peripherals = [[NSMutableArray alloc] init];
    peripheralsAD = [[NSMutableArray alloc] init];
    if (ConnectedAD)
    {
        [peripherals addObject:ConnectedPeripheral];
        [peripheralsAD addObject:ConnectedAD];
    }
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    _mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, 15, 40, 40)];
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithRed:(247.0 / 255.0f) green:(247.0 /255.0f) blue:(240.0 / 255.0f) alpha:1.0f];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _myTableView.tableHeaderView = [self customHeaderView];
    _myTableView.tableFooterView = [self customFootherView];
}
#pragma mark -蓝牙配置和操作
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf insertTableView:peripheral advertisementData:advertisementData];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"搜索到服务:%@",service.UUID.UUIDString);
        }
        //找到cell并修改detaisText
        for (int i=0;i<peripherals.count;i++) {
            UITableViewCell *cell = [weakSelf.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:3]];
            if ([cell.textLabel.text isEqualToString:peripheral.name]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)peripheral.services.count];
            }
        }
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备
        if (_device_Name.text.length > 0)
        {
            if ([peripheralName hasPrefix:weakSelf.device_Name.text] ) {
                return YES;
            }
            return NO;
        }
        else
        {
            //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
            if (peripheralName.length >0) {
                return YES;
            }
            return NO;
        }
    }];

    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
#pragma mark -UIViewController 方法
//插入table数据
-(void)insertTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if(![peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:peripherals.count inSection:3];
        [indexPaths addObject:indexPath];
        [peripherals addObject:peripheral];
        [peripheralsAD addObject:advertisementData];
        [self.myTableView reloadData];
    }
}
#pragma mark - tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3)
    {
        return 40;
    }
    else if (section == 2)
    {
        return 300;
    }
    else if (section == 1)
    {
        return 80;
    }
    else
    {
        return 60;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3)
    {
        if (peripherals.count > 0)
        {
            return peripherals.count;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 0;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
        view.backgroundColor = [UIColor whiteColor];
        _device_Name.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width-20, 60);
        _device_Name.backgroundColor = [UIColor whiteColor];
        _device_Name.placeholder = @"请输入设备名前缀";
        _device_Name.keyboardType = UIKeyboardTypeWebSearch;
        [view addSubview:_device_Name];
        UILabel *graylabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 59.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
        graylabel.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1.0];
        [view addSubview:graylabel];
        return view;
    }
    else if (section == 1)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
        view.backgroundColor = [UIColor whiteColor];
        _device_PIN.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width-60, 60);
        _device_PIN.backgroundColor = [UIColor whiteColor];
        _device_PIN.placeholder = @"请输入设备PIN码";
        _device_PIN.enabled = NO;
        [view addSubview:_device_PIN];
        [view addSubview:_mySwitch];
        UILabel *Remindlabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, [UIScreen mainScreen].bounds.size.width-40, 20)];
        Remindlabel.textColor = RGBColor(153, 153, 153);
        Remindlabel.text = @"开关打开表示手动输入PIN码，开关关闭表示自动输入PIN码。";
        Remindlabel.font = [UIFont systemFontOfSize:10];
        [view addSubview:Remindlabel];
        return view;
    }
    else if (section == 2)
    {
        UIView *view = [UIView new];
        view.backgroundColor = RGBColor(247, 105, 86);
        view.frame = CGRectMake(0, 0, ScreenWidth, 300);
       
        BluetoothView *bluetooth = [[BluetoothView alloc] initWithFrame:CGRectMake(ScreenWidth/2.0-40, 120, 80, 80)];
        bluetooth.center = view.center;
        if (isselect == NO)
        {
            [view addSubview:bluetooth];
        }
        else
        {
            [bluetooth removeFromSuperview];
        }
        
        [_connectBtn addTarget:self action:@selector(changeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_connectBtn];
        [view addSubview:_connectResult];
        return view;
    }
    else
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        view.backgroundColor = [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1.0f];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, tableView.frame.size.width-10, 20)];
        titleLabel.text = @"设备列表";
        titleLabel.textColor = [UIColor blackColor];
        [view addSubview:titleLabel];
        return view;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        if (peripherals.count > 0)
        {
            CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
            NSDictionary *ad = [peripheralsAD objectAtIndex:indexPath.row];
            UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"Cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            NSInteger row = [indexPath row];
            NSInteger oldRow = [lastPath row];
            if (row == oldRow && lastPath!=nil) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //peripheral的显示名称,优先用kCBAdvDataLocalName的定义，若没有再使用peripheral name
            NSString *localName;
            if ([ad objectForKey:@"kCBAdvDataLocalName"]) {
                localName = [NSString stringWithFormat:@"%@",[ad objectForKey:@"kCBAdvDataLocalName"]];
            }else{
                localName = peripheral.name;
            }
            cell.textLabel.text = localName;
            if (indexPath.row == 0)
            {
                if (ConnectedAD)
                {
                    cell.textLabel.text = [NSString stringWithFormat:@"最近连接｜%@",localName];
                }
            }
            //信号和服务
            cell.detailTextLabel.text = @"读取中...";
            //找到cell并修改detaisText
            NSArray *serviceUUIDs = [ad objectForKey:@"kCBAdvDataServiceUUIDs"];
            if (serviceUUIDs) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu个service",(unsigned long)serviceUUIDs.count];
            }else{
                cell.detailTextLabel.text = [NSString stringWithFormat:@"0个service"];
            }
            //次线程读取RSSI和服务数量
            return cell;
        }
        else
        {
            UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
                cell.backgroundColor = [UIColor clearColor];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
                label.font = [UIFont systemFontOfSize:14];
                label.text = @"暂无可链接的蓝牙设备";
                label.textAlignment = NSTextAlignmentCenter;
                [cell.contentView addSubview:label];
            }
            return cell;
        }
    }
    else
    {
        return nil;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3)
    {
        if (peripherals.count > 0)
        {
            NSUInteger newRow = [indexPath row];
            NSUInteger oldRow = (lastPath !=nil)?[lastPath row]:-1;
            if (newRow != oldRow) {
                UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
                newCell.accessoryType = UITableViewCellAccessoryCheckmark;
                UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastPath];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
                lastPath = indexPath;
            }
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            _myTableView.userInteractionEnabled = NO;
            _connectResult.text = @"搜索结束";
            isselect = YES;
            [baby cancelScan];
            [_myTableView reloadData];
            self.currPeripheral = [peripherals objectAtIndex:indexPath.row];
            self.bluetoothAD = [peripheralsAD objectAtIndex:indexPath.row];
            isSelectNumber = indexPath.row;
            [baby cancelAllPeripheralsConnection];    //停止之前的连接
            [self connectBluetooth];
            [self performSelector:@selector(NewtimerTask) withObject:nil afterDelay:1];
        }
    }
}
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.04*ScreenHeight)];
    headerV.backgroundColor = [UIColor clearColor];
    return headerV;
}
- (UIView *)customFootherView
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.04*ScreenHeight)];
    headerV.backgroundColor = [UIColor clearColor];
    return headerV;
}
-(void)viewDidLayoutSubviews
{
    if ([_myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_myTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_myTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
#pragma mark - textFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _device_Name)
    {
        if (_device_Name.text.length > 0)
        {
            if (isselect == NO)
            {
                _connectResult.text = @"搜索结束";
                isselect = YES;
                [baby cancelScan];
                [_myTableView reloadData];
            }
        }
    }
    return YES;
}
#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //第一次打开或者每次蓝牙状态改变都会调用这个函数
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        blueToothOpen = YES;
    }
    else
    {
        blueToothOpen = NO;
    }
}
- (void)connectBluetooth
{
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
        ConnectedPeripheral = weakSelf.currPeripheral;
        ConnectedAD = weakSelf.bluetoothAD;
        weakSelf.myTableView.userInteractionEnabled = YES;
    }];

    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
        weakSelf.myTableView.userInteractionEnabled = YES;
    }];

    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
        weakSelf.myTableView.userInteractionEnabled = YES;
    }];

    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
//        for (CBService *s in peripheral.services) {
//            ///插入section到tableview
////            [weakSelf insertSectionToTableView:s];
//        }
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        //插入row到tableview
//        [weakSelf insertRowToTableView:service];

    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    //读取rssi的委托
    [baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    //设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsBreak call");
        //如果完成任务，即可停止beat,返回bry可以省去使用weak rhythm的麻烦
        //        if (<#condition#>) {
//        [bry beatsOver];
        //        }
    }];

    //设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) {
        NSLog(@"setBlockOnBeatsOver call");
    }];

    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}
#pragma mark - 开始连接设备
- (void)NewtimerTask
{
    [SVProgressHUD show];
    [SVProgressHUD showWithStatus:@"连接中..."];
    baby.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
//        baby.connectToPeripheral(self.currPeripheral).begin();
}
- (void)changeBtn:(UIButton *)sender
{
    if (blueToothOpen)
    {
        if (isselect == YES)
        {
            if (_device_Name.text.length > 0)
            {
                [peripheralsAD removeAllObjects];
                [peripherals removeAllObjects];
            }
            _connectResult.text = @"正在搜索...";
            isselect = NO;
            [_myTableView reloadData];
            baby.scanForPeripherals().begin();
            //设置蓝牙委托
            [self babyDelegate];
        }
        else
        {
            _connectResult.text = @"搜索结束";
            isselect = YES;
            [baby cancelScan];
            [_myTableView reloadData];
            if (peripherals.count == 1)
            {
                [self tableView:self.myTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:3]];
            }
        }
    }
    else
    {
        [self.view makeToast:@"当前设备蓝牙没开,请打开后再试..." duration:2 position:@"center"];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
//    baby.scanForPeripherals().begin();
    //baby.scanForPeripherals().begin().stop(10);
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //停止之前的连接
    [baby cancelAllPeripheralsConnection];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
