/**
 *Submitted for verification at BscScan.com on 2022-02-25
*/

//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

abstract contract Owner {
    address public owner;
    constructor () {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function isOwner() internal view returns (bool) {
        return owner == msg.sender;
    }

    function setOwner(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        owner = _newOwner;
    }
}

abstract contract ActiveAdmin is Owner {

    mapping(address => bool) private _activeAdmins;

    modifier onlyActiveAdmin() {
        require(isActiveAdmin(msg.sender));
        _;
    }
    function isActiveAdmin(address account) internal view returns (bool) {
        return _activeAdmins[account];
    }

    function addActiveAdmin(address account) public onlyOwner {
        require(account != address(0));
        _activeAdmins[account] = true;
    }

    function removeActiveAdmin(address account) public onlyOwner {
        require(account != address(0));
        delete _activeAdmins[account];
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20, ActiveAdmin{

    //交易池信息
    struct SwapTerm {
        uint termId;
        uint termStartTime;
        uint termEndTime;
        uint amount;
        bool stop;
        uint timePerAdd;
    }
    
    //基础信息
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply = 0;
    uint256 private _totalBurn = 0;
    uint256 private _remainRewardFreeze = 121000000000000; //剩余的盲盒奖励锁仓
    uint256 private _remainPoolFreeze = 10000000000000;//剩余的奖池奖励锁仓 交易池的初始释放
    uint256 private _gameMintFreeze = 50000000000000; //剩余的游戏锁仓
    uint256 private planTotalSupply = 198000000000000; //封顶发行

    
    address private bonusAddress; //指定地址
    address[] private sysCreators; //所有创世
    address[] private sysGenesises; //所有超级节点
    address[] private sysNodes; //所有节点
    mapping(address => uint) private upgradeTimes; //升级时间
    mapping(address => address) private creators; //所属创世
    mapping(address => address) private genesises; //所属创世节点
    mapping(address => address) private nodes; //所属节点
    mapping(address => address) private parents;//所属直推人
    mapping(address => address[]) private children;//直推下级

    //Swap池
    address private swapPoolAddress; //swap奖池地址
    mapping(address => bool) private swapMainAddresses; //交易所地址
    mapping(uint256 => SwapTerm) private swapTerms;
    uint private constant initSwapTermTime = 24 hours; //每一期时长
    uint private currSwapTermId = 0; //当前期的编号
    mapping(uint => address[]) private swapTermJoinAddresses; //第几期 => 加入地址集合

    //盲盒
    bool private supportActive = true;
    mapping(address => uint) private activeTimes;
    mapping(address => uint) private blindBoxTimes;
    mapping(address => uint) private totalGains;
    mapping(address => uint) private levels;
    uint private constant blindBoxFee = 3000000000;
    uint private constant feeGainTotal = 3000000000;
    uint private constant freeGainTotal = 1000000000;
 
    //抽装备 
    struct JoinInfo {
        address account; //地址 
        uint num;  // 0-9代表数字 10代表双 11代表单 12代表大 13代表小
        uint amount; //数量
    }
    
    mapping(uint => JoinInfo[]) private joinInfos;
    uint private constant startTime = 1644508800;

    //锁仓
    address private freezeAdminAddress; //锁仓指定地址 
    struct FreezeInfo {
        address account; //地址 
        uint freezeAmount; //数量
        uint freezeTime;
    }
    FreezeInfo[] private freezeInfos;

    function isFreezeAccount(address account) public view returns (bool){
        if(getFreezeTime(account) > 0 && blockTime().sub(getFreezeTime(account)) < 1096 days){
            return true;
        }
        return false;
    }

    function getTotalFreezeAmount() public view returns (uint){
        uint total = 0;
        if(freezeInfos.length > 0){
            for (uint256 i = 0; i < freezeInfos.length; i++) {
                if(isFreezeAccount(freezeInfos[i].account)){
                    total = total.add(freezeInfos[i].freezeAmount);
                }
            }
        }
        return 0; 
    }

    function getFreezeAmount(address account) public view returns (uint){
        if(freezeInfos.length > 0){
            for (uint256 i = 0; i < freezeInfos.length; i++) {
                if(account == freezeInfos[i].account){
                    return freezeInfos[i].freezeAmount;
                }
            }
        }
        return 0; 
    }

    function getFreezeTime(address account) public view returns (uint){
        if(freezeInfos.length > 0){
            for (uint256 i = 0; i < freezeInfos.length; i++) {
                if(account == freezeInfos[i].account){
                    return freezeInfos[i].freezeTime;
                }
            }
        }
        return 0;
    }

    function getUpgradeTime(address account) public view returns (uint){
        return upgradeTimes[account];
    }

    function getCreators() public view returns (address[] memory){
        return sysCreators;
    }

    function getGenesises() public view returns (address[] memory){
        return sysGenesises;
    }

    function getNodes() public view returns (address[] memory){
        return sysNodes;
    }

    function isCreator(address addr) public view returns (bool){
        if(sysCreators.length > 0){
            for (uint256 i = 0; i < sysCreators.length; i++) {
                if(addr == sysCreators[i]){
                    return true;
                }
            }
        }
        return false; 
    }

    function isGenesis(address addr) public view returns (bool){
        if(sysGenesises.length > 0){
            for (uint256 i = 0; i < sysGenesises.length; i++) {
                if(addr == sysGenesises[i]){
                    return true;
                }
            }
        }
        return false; 
    }

    function isNode(address addr) public view returns (bool){
        if(sysNodes.length > 0){
            for (uint256 i = 0; i < sysNodes.length; i++) {
                if(addr == sysNodes[i]){
                    return true;
                }
            }
        }
        return false; 
    }

    function blockTime() public view returns (uint){
        return block.timestamp;
    }
    
    function swapTermIsValid(uint swapTermId) internal view returns (bool){
        SwapTerm memory swapTerm = swapTerms[swapTermId];
        return block.timestamp > swapTerm.termStartTime && block.timestamp < swapTerm.termEndTime;
    }

    function setFreezeAdminAddress(address account) public onlyOwner returns (bool success) {
        freezeAdminAddress = account;
        return true;
    }

    function setSwapMainAddress(address account) public onlyOwner returns (bool success) {
        swapMainAddresses[account] = true;
        return true;
    }

    function removeSwapMainAddress(address account) public onlyOwner returns (bool success) {
        delete swapMainAddresses[account];
        return true;
    }

    function isSwapMainAddress(address account) public view returns(bool){
        return swapMainAddresses[account];
    }
    
    function getSwapPoolAddress() public view returns(address){
        return swapPoolAddress;
    }

    function getCurrSwapTermId() internal view returns (uint){
        return currSwapTermId;
    }

    event NewSwapTerm(uint256 indexed swapTermId);

    event StopSwapTerm(uint256 indexed swapTermId);

    constructor (address _bonusAddress, address _swapPoolAddress, string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
        bonusAddress = _bonusAddress;
        swapPoolAddress = _swapPoolAddress;
        _name = tokenName;
        _symbol = tokenSymbol;
        _decimals = tokenDecimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function totalBurn() public view returns (uint256) {
        return _totalBurn;
    }

    function totalRewardFreeze() public view returns (uint256) {
        return _remainRewardFreeze;
    }

    function totalPoolFreeze() public view returns (uint256) {
        return _remainPoolFreeze;
    }

    function totalGameMintFreeze() public view returns (uint256) {
        return _gameMintFreeze;
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(msg.sender != swapPoolAddress);
        if(isSwapMainAddress(recipient)){
            require(amount >= 10);
            _burn(msg.sender, amount.mul(10).div(100));
            _transfer(msg.sender, recipient, amount.mul(90).div(100));
            return true;
        } else {    
            _transfer(msg.sender, recipient, amount);
            if(isOwner()){
                if(amount == 50000000000){
                    internalUpgrade(1, recipient);
                } 
                if(amount == 10000000000){
                    internalUpgrade(2, recipient);
                }  
                if(amount == 2000000000){
                    internalUpgrade(3, recipient);  
                }
                return true;             
            } 
            if(msg.sender == freezeAdminAddress){
                if(getFreezeTime(recipient) == 0){
                    freezeInfos.push(FreezeInfo(recipient, amount, blockTime()));
                }               
                return true;
            }
            if (recipient != swapPoolAddress && msg.sender != swapPoolAddress) {
                if (isCreator(msg.sender) || isGenesis(msg.sender) || isNode(msg.sender)) {
                    if (parents[recipient] == address(0)) {
                        if(isCreator(msg.sender)){
                            creators[recipient] = msg.sender;
                        } else {
                            if (creators[msg.sender] != address(0)) {
                                creators[recipient] = creators[msg.sender];
                            }
                        }
                        if(isGenesis(msg.sender)){
                            genesises[recipient] = msg.sender;
                        } else {
                            if (genesises[msg.sender] != address(0)) {
                                genesises[recipient] = genesises[msg.sender];
                            }
                        }
                        if(isNode(msg.sender)){
                            nodes[recipient] = msg.sender;
                        } else {
                            if (nodes[msg.sender] != address(0)) {
                                nodes[recipient] = nodes[msg.sender];
                            }
                        }
                        parents[recipient] = msg.sender;
                        children[msg.sender].push(recipient);
                        return true;
                    }
                }       
            }
        }
        return false;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(msg.sender != swapPoolAddress);
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(msg.sender != swapPoolAddress);
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(msg.sender != swapPoolAddress);
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require( msg.sender != swapPoolAddress);
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0) && spender != address(0));
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function internalUpgrade(uint8 _type, address account) internal returns (bool) {
        if (_type == 1 && upgradeTimes[account] == 0 && _balances[account] >= 50000000000) {
            if(!isCreator(account)){
                creators[account] = account;
                sysCreators.push(account);
            }  
            if(!isGenesis(account)){
                genesises[account] = account;
                sysGenesises.push(account);
            }
            if(!isNode(account)){
                nodes[account] = account;
                sysNodes.push(account);
            }
            upgradeTimes[account] = block.timestamp;
            return true;                  
        }
        if (_type == 2 && upgradeTimes[account] == 0 && _balances[account] >= 10000000000) {
            if(!isGenesis(account)){
                genesises[account] = account;
                sysGenesises.push(account);
            }
            if(!isNode(account)){
                nodes[account] = account;
                sysNodes.push(account);
            }
            upgradeTimes[account] = block.timestamp;
            return true;                  
        }
        if (_type == 3 && !isNode(account) && upgradeTimes[account] == 0 && _balances[account] >= 2000000000) {
            nodes[account] = account;
            sysNodes.push(account);
            upgradeTimes[account] = block.timestamp;
            return true;           
        }
        return false;
    }

    function upgrade(uint8 _type) public returns (bool) {
        return internalUpgrade(_type, msg.sender);
    }

    function gameMint(address account, uint amount) public onlyOwner returns (bool success) {
        return _gameMint(account, amount);
    }

    function _gameMint(address account, uint256 amount) internal returns (bool){
        if (_gameMintFreeze > amount) {
            _gameMintFreeze = _gameMintFreeze.sub(amount);
            return _mint(account, amount);
        }
        return false;
    }
     

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0) && recipient != address(0));
        if (sender != swapPoolAddress && !isSwapMainAddress(sender)) {
            require(_balances[sender] >= amount.add(getUserFreeze(sender)), "Insufficient balance...");
        } else {
            require(_balances[sender] >= amount, "balance not enough revert...");
        }
        if(currSwapTermId > 0){
            SwapTerm memory swapTerm = swapTerms[currSwapTermId];
            if(isSwapMainAddress(sender) && amount >= swapTerm.amount){
                successSwapPoolBiz(recipient);
            }
        }
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function doOpenBlindbox() public returns (bool){
        if(_balances[msg.sender] >= getUserFreeze(msg.sender).add(blindBoxFee)){
            openBlindbox(msg.sender);
            return true;
        }
        return false;
    }

    function _batchTransfer(address[] memory addresses, uint256[] memory amounts) public returns (bool){
        for (uint256 i = 0; i < addresses.length; i++) {
            _transfer(msg.sender, addresses[i], amounts[i]);
        }
        return true; 
    }

    function _mint(address account, uint256 amount) internal returns (bool){
        if (_totalSupply.add(amount) <= planTotalSupply) {
            _totalSupply = _totalSupply.add(amount);
            _balances[account] = _balances[account].add(amount);
            emit Transfer(address(0), account, amount);
            return true;
        }
        return false;
    }
    
    
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        if (account != swapPoolAddress && !isSwapMainAddress(account)) {
            require(_balances[account] >= value.add(getUserFreeze(account)), "Insufficient balance...");
        } else {
            require(_balances[account] >= value, "balance not enough revert...");
        }
        _totalSupply = _totalSupply.sub(value);
        _totalBurn = _totalBurn.add(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    

    function _rewardMint(address account, uint256 amount) internal returns (bool){
        if (_remainRewardFreeze > amount) {
            _remainRewardFreeze = _remainRewardFreeze.sub(amount);
            return _mint(account, amount);
        }
        return false;
    }

    function _poolMint(address account, uint256 amount) internal returns (bool){
        if (_remainPoolFreeze > amount) {
            _remainPoolFreeze = _remainPoolFreeze.sub(amount);
            return _mint(account, amount);
        }
        return false;
    }

    function userInfo(address addr) public view returns (uint _balance, address _creator, address _genesis, address _node, address _parent, bool _isCreator, bool _isGenesis, bool _isNode){
        _balance = _balances[addr];
        _creator = creators[addr];
        _genesis = genesises[addr];
        _node = nodes[addr];
        _parent = parents[addr];
        _isCreator = isCreator(addr);
        _isGenesis = isGenesis(addr);
        _isNode = isNode(addr);
    }

    function userChildren(address addr) public view returns (address[] memory _children){
        _children = children[addr];
    }

    //交易池
    function addSwapTerm(uint amount, uint timePerAdd, uint poolAmount) public onlyOwner returns (bool success) {
        if (currSwapTermId >= 1) {
            require(swapTerms[currSwapTermId].stop);
        }
        currSwapTermId++;
        uint currTime = blockTime();
        SwapTerm storage swapTerm = swapTerms[currSwapTermId];
        swapTerm.termId = currSwapTermId;
        swapTerm.termStartTime = currTime;
        swapTerm.termEndTime = currTime.add(initSwapTermTime);
        swapTerm.amount = amount;
        swapTerm.timePerAdd = timePerAdd;
        emit NewSwapTerm(currSwapTermId);
        _poolMint(swapPoolAddress, poolAmount);
        return true;
    }
    
    function stopSwapTerm() public onlyOwner returns (bool success) {
        SwapTerm storage swapTerm = swapTerms[currSwapTermId];
        if (!swapTerm.stop && blockTime() > swapTerm.termEndTime) {
            swapTerm.termEndTime = blockTime();
            swapTerm.stop = true;
            emit StopSwapTerm(currSwapTermId);
            if (_balances[swapPoolAddress] > 0) {
                uint length = swapTermJoinAddresses[currSwapTermId].length;
                if (length > 10) {
                    uint swapPoolBalance = _balances[swapPoolAddress];
                    for (uint256 i = length - 1; i >= length - 10; i--) {
                        if (i == length - 1) {
                            _transfer(swapPoolAddress, swapTermJoinAddresses[currSwapTermId][i], swapPoolBalance.mul(50).div(100));
                        } else if (i == length - 2) {
                            _transfer(swapPoolAddress, swapTermJoinAddresses[currSwapTermId][i], swapPoolBalance.mul(10).div(100));
                        } else {
                            _transfer(swapPoolAddress, swapTermJoinAddresses[currSwapTermId][i], swapPoolBalance.mul(5).div(100));
                        }
                    }
                }
            }
            return true;
        }
        return false;
    }
    
    function successSwapPoolBiz(address account) internal {
        if (swapTermIsValid(currSwapTermId)) {
            SwapTerm storage storageSwapTerm = swapTerms[currSwapTermId];
            swapTermJoinAddresses[currSwapTermId].push(account);
            if (storageSwapTerm.termEndTime.add(storageSwapTerm.timePerAdd).sub(blockTime()) < initSwapTermTime) {
                storageSwapTerm.termEndTime = storageSwapTerm.termEndTime.add(storageSwapTerm.timePerAdd);
            } else {
                storageSwapTerm.termEndTime = blockTime() + initSwapTermTime;
            }
        }
    }
    
    function currSwapTermInfo() public view returns (uint _swapTermId, uint _startTime, uint _endTime, uint _blockTime, uint _amount, bool _stop){
        SwapTerm memory swapTerm = swapTerms[currSwapTermId];
        _swapTermId = currSwapTermId;
        _startTime = swapTerm.termStartTime;
        _endTime = swapTerm.termEndTime;
        _amount = swapTerm.amount;
        _blockTime = blockTime();
        _stop = swapTerm.stop;
    }

    function swapTermInfo(uint swapTermId) public view returns (uint _startTime, uint _endTime, uint _blockTime, uint _amount, bool _stop){
        SwapTerm memory swapTerm = swapTerms[swapTermId];
        _startTime = swapTerm.termStartTime;
        _endTime = swapTerm.termEndTime;
        _amount = swapTerm.amount;
        _blockTime = blockTime();
        _stop = swapTerm.stop;
    }
    
    function getUserFreeze(address account) public view returns(uint){
        uint total = 1000000;
        if(userIsOpen(account) && calcBlindboxReward(account) < feeGainTotal){
            total = total.add(blindBoxFee);
        }
        if(upgradeTimes[account] > 0 && blockTime().sub(upgradeTimes[account]) < 723 days){
            if(isCreator(account)){
                total = total.add(50000000000);
            } else if(!isCreator(account) && isGenesis(account)){
                total = total.add(10000000000);
            } else if(!isCreator(account) && !isGenesis(account) && isNode(account)){
                total = total.add(2000000000);
            }
        }
        if(isFreezeAccount(account)){
            total = total.add(getFreezeAmount(account));
        }  
        return total;
    }
    
    function getSwapTermJoinTimes(uint swapTermId, address account) public view returns (uint) {
        uint sum = 0;
        uint length = swapTermJoinAddresses[swapTermId].length;
        if(length > 0){
            for (uint256 i = 0; i < length; i++) {
                if (account == swapTermJoinAddresses[swapTermId][i]) {
                    sum += 1;
                }
            }   
        }
        return sum;
    }
    
    function getSwapWinners(uint swapTermId) public view returns (address winner1, address winner2, address winner3, address winner4, address winner5, address winner6, address winner7, address winner8, address winner9, address winner10){
        uint length = swapTermJoinAddresses[swapTermId].length;
        if (length >= 1) {
            winner1 = swapTermJoinAddresses[swapTermId][length-1];
        }
        if (length >= 2) {
            winner2 = swapTermJoinAddresses[swapTermId][length-2];
        }
        if (length >= 3) {
            winner3 = swapTermJoinAddresses[swapTermId][length-3];
        }
        if (length >= 4) {
            winner4 = swapTermJoinAddresses[swapTermId][length-4];
        }
        if (length >= 5) {
            winner5 = swapTermJoinAddresses[swapTermId][length-5];
        }
        if (length >= 6) {
            winner6 = swapTermJoinAddresses[swapTermId][length-6];
        }
        if (length >= 7) {
            winner7 = swapTermJoinAddresses[swapTermId][length-7];
        }
        if (length >= 8) {
            winner8 = swapTermJoinAddresses[swapTermId][length-8];
        }
        if (length >= 9) {
            winner9 = swapTermJoinAddresses[swapTermId][length-9];
        }
        if (length >= 10) {
            winner10 = swapTermJoinAddresses[swapTermId][length-10];
        }
    }
    
    //盲盒业务
    function updateSupportActive() public onlyOwner returns (bool) {
        supportActive = !supportActive;
        return true;
    }
    

    function getSupportActive() public view returns (bool) {
        return supportActive;
    }
    
    function doActive(address account) public onlyActiveAdmin returns (bool) {
        require(supportActive);
        require(activeTimes[account] == 0);
        activeTimes[account] = block.timestamp;
        return true;
    }

    function getGameUserInfo(address addr) public view returns (uint activeTime, uint blindBoxTime, uint level, uint gain, bool open, uint feeMinerSpeed, uint freeMinerSpeed, uint freeTotal, uint feeTotal, uint remainTotal) {
        activeTime = activeTimes[addr];
        blindBoxTime = blindBoxTimes[addr];
        level = levels[addr];
        gain = totalGains[addr];
        open = blindBoxTimes[addr] > 0;
        freeTotal = calcFreeMinerReward(addr);
        feeTotal = calcBlindboxReward(addr);
        remainTotal = freeTotal.add(feeTotal).sub(totalGains[addr]);
        if(blindBoxTimes[addr] > 0 && feeTotal < feeGainTotal){
            feeMinerSpeed = getMinerSpeed(level);
        }
        if(activeTimes[addr] > 0 && freeTotal < freeGainTotal){
            freeMinerSpeed = getMinerSpeed(1);
        }
    }

    function getBlindBoxNumber() internal view returns (uint8) {
        uint8 randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 100) + 1;
        if(randomNumber <= 3){
            return 2;
        } else if(randomNumber > 3 && randomNumber <= 8){
            return 3;
        } else if(randomNumber > 8 && randomNumber <= 18){
            return 4;
        } else if(randomNumber > 18 && randomNumber <= 38){
            return 5;
        } else if(randomNumber > 38 && randomNumber <= 78){
            return 6;
        } else if(randomNumber > 78 && randomNumber <= 88){
            return 7;
        } else if(randomNumber > 88 && randomNumber <= 95){
            return 8;
        } else if(randomNumber > 95 && randomNumber <= 98){
            return 9;
        } else if(randomNumber > 98 && randomNumber <= 100){
            return 10;
        }
        return randomNumber;
    }


    function updateGameUserLevel(address addr, uint level) internal returns (bool){
        require(blindBoxTimes[addr] == 0);
        blindBoxTimes[addr] = block.timestamp;
        levels[addr] = level;
        return true;
    }


    function userIsOpen(address addr) internal view returns (bool){
        return blindBoxTimes[addr] > 0;
    }

    function getMinerSpeed(uint level) internal pure returns (uint){
        if(level == 1){
            return 23;
        } else if (level == 2){
            return 231;
        } else if (level == 3){
            return 248;
        } else if (level == 4){
            return 267;
        } else if (level == 5){
            return 289;
        } else if (level == 6){
            return 315;
        } else if (level == 7){
            return 347;
        } else if (level == 8){
            return 385;
        } else if (level == 9){
            return 496;
        } else if (level == 10){
            return 694;
        }
        return 0;
    }

    function calcBlindboxReward(address addr) public view returns(uint){
        if(blindBoxTimes[addr] > 0){
            uint level = levels[addr];
            uint totalTime = block.timestamp - blindBoxTimes[addr];
            uint total = totalTime.mul(getMinerSpeed(level));
            return total > feeGainTotal ? feeGainTotal : total;
        }
        return 0;
    }
    
    function calcFreeMinerReward(address addr) public view returns(uint){
        if(activeTimes[addr] > 0){
            uint totalTime = block.timestamp - activeTimes[addr];
            uint total = totalTime.mul(getMinerSpeed(1));
            return total > freeGainTotal ? freeGainTotal : total;
        }
        return 0;
    }
    
    function openBlindbox(address account) internal returns(uint){
        uint level = getBlindBoxNumber();
        updateGameUserLevel(account, level);
        return level;
    }


    function getReward() public returns(bool){
        if(blindBoxTimes[msg.sender] > 0 && activeTimes[msg.sender] > 0){
            uint _reward1 = calcBlindboxReward(msg.sender);
            uint _reward2 = calcFreeMinerReward(msg.sender);
            uint reward = _reward1.add(_reward2).sub(totalGains[msg.sender]); 
            if(reward > 0 && reward.add(totalGains[msg.sender]) <= freeGainTotal.add(feeGainTotal)){
                _rewardMint(msg.sender, reward);
                totalGains[msg.sender] = totalGains[msg.sender].add(reward);
                return true;
            }
            
        }
        if(blindBoxTimes[msg.sender] == 0 && activeTimes[msg.sender] > 0){
            uint _reward2 = calcFreeMinerReward(msg.sender);
            uint reward = _reward2.sub(totalGains[msg.sender]);
            if(reward > 0 && reward.add(totalGains[msg.sender]) <= freeGainTotal){
                _rewardMint(msg.sender, reward);
                totalGains[msg.sender] = totalGains[msg.sender].add(reward);
                return true;
            }
        }
        if(blindBoxTimes[msg.sender] > 0 && activeTimes[msg.sender] == 0){
            uint _reward1 = calcBlindboxReward(msg.sender);
            uint reward = _reward1.sub(totalGains[msg.sender]);
            if(reward > 0 && reward.add(totalGains[msg.sender]) <= feeGainTotal){
                _rewardMint(msg.sender, reward);
                totalGains[msg.sender] = totalGains[msg.sender].add(reward);
                return true;
            }
        }
        return false;
    }
    
    //抽数字
    function join(uint8 num, uint amount) public returns (bool){
        require(num>=0 && num<=13);
        uint termId = getCurrJoinTermId();
        require(!hasJoin(msg.sender, termId));
        joinInfos[termId].push(JoinInfo(msg.sender, num, amount));
        _transfer(msg.sender, bonusAddress, amount);
        return true;
    }
    
    
    function getJoinTermId(uint timestamp) public pure returns (uint){
        uint sub = timestamp.sub(startTime);
        uint termId = sub.div(1 days) + 1;
        return termId;
    }
    
    function getCurrJoinTermId() public view returns (uint){
        return getJoinTermId(blockTime());
    }
    
    function hasJoin(address account, uint termId) public view returns (bool){
        JoinInfo[] memory info = joinInfos[termId];
        if(info.length > 0){
            for (uint256 i = 0; i < info.length; i++) {
                if(info[i].account == account){
                    return true;
                }
            }
        }
        return false;
     }
     
     function joinInfo(uint termId, address account) public view returns (uint num, uint amount){
        JoinInfo[] memory info = joinInfos[termId];
        if(info.length > 0){
            for (uint256 i = 0; i < info.length; i++) {
                if(info[i].account == account){
                    num = info[i].num;
                    amount = info[i].amount;
                }
            }
        }
    }

    function calcTotal(uint8 termId, uint8 number) public view returns (uint){
        JoinInfo[] memory info = joinInfos[termId];
        if(info.length > 0){
            uint total = 0;
            for (uint256 i = 0; i < info.length; i++) {
                if(info[i].num == number){
                    total += info[i].amount;
                } 
            }
            return total;
        }
        return 0;
    }

    function calcPartTotal(uint8 termId, uint8 _type) public view returns (uint){
        JoinInfo[] memory info = joinInfos[termId];
        //0-9代表数字 10代表双 11代表单 12代表大 13代表小  
        if(info.length > 0){
            uint total = 0;
            for (uint256 i = 0; i < info.length; i++) {
                if(_type == 1){ //singleSmall
                    if(info[i].num == 1 || info[i].num == 3){
                        total += info[i].amount.mul(5);
                    }
                    if(info[i].num == 11 || info[i].num == 13){
                        total += info[i].amount;
                    }  
                } else if(_type == 2){ //doubleSmall
                    if(info[i].num == 0 || info[i].num == 2 || info[i].num == 4){
                        total += info[i].amount.mul(5);
                    } 
                    if(info[i].num == 10 || info[i].num == 13){
                        total += info[i].amount;
                    } 
                } else if(_type == 3){ //doubleBig
                    if(info[i].num == 6 || info[i].num == 8){
                        total += info[i].amount.mul(5);
                    } 
                    if(info[i].num == 10 || info[i].num == 12){
                        total += info[i].amount;
                    } 
                } else if(_type == 4){ //singleBig
                    if(info[i].num == 5 || info[i].num == 7 || info[i].num == 9){
                        total += info[i].amount.mul(5);
                    }
                    if(info[i].num == 11 || info[i].num == 12){
                        total += info[i].amount;
                    }
                }
            }
            return total;
        }
        return 0;
    }

    function getMin(uint a, uint b) internal pure returns (uint){
        return a <= b ? a : b;
    }

    function getNumber(uint8 termId) public view returns (uint){
        JoinInfo[] memory info = joinInfos[termId];
        //0-9代表数字 10代表双 11代表单 12代表大 13代表小
        if(info.length > 0){
            uint singleSmall = calcPartTotal(termId, 1); //singleSmall
            uint doubleSmall = calcPartTotal(termId, 2); //doubleSmall
            uint doubleBig = calcPartTotal(termId, 3); //doubleBig
            uint singleBig = calcPartTotal(termId, 4); //singleBig
            uint minPartTotal = getMin(getMin(singleSmall, doubleSmall), getMin(doubleBig, singleBig));
            if(minPartTotal == singleSmall){
                return calcTotal(termId, 1) <= calcTotal(termId, 3) ? 1 : 3;
            }
            if(minPartTotal == doubleSmall){
                uint total0 = calcTotal(termId, 0);
                uint total2 = calcTotal(termId, 2);
                uint total4 = calcTotal(termId, 4);
                if(total0 <= total2 && total0 <= total4){
                    return 0;
                } else if(total2 <= total0 && total2 <= total4){
                    return 2;
                } else if(total4 <= total0 && total4 <= total2){
                    return 4;
                } 
            }
            if(minPartTotal == doubleBig){
                return calcTotal(termId, 6) <= calcTotal(termId, 8) ? 6 : 8;
            }
            if(minPartTotal == singleBig){
                uint total5 = calcTotal(termId, 5);
                uint total7 = calcTotal(termId, 7);
                uint total9 = calcTotal(termId, 9);
                if(total5 <= total7 && total5 <= total9){
                    return 5;
                } else if(total7 <= total5 && total7 <= total9){
                    return 7;
                } else if(total9 <= total5 && total9 <= total7){
                    return 9;
                } 
            }
        }
        return 100;
    }

    
}

contract HEHEToken is ERC20 {
    constructor (address bonusAddress, address totalAddress, address swapPoolAddress) 
        ERC20(bonusAddress, swapPoolAddress, "HEHE Coin", "HEHE", 6) {
        _mint(totalAddress, 17000000 * (10 ** uint256(decimals())));
    }
}