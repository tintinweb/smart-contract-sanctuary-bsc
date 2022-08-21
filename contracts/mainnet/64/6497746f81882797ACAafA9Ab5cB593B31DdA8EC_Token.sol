/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity ^0.8.15;
// SPDX-License-Identifier: MIT


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the ow  ner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




contract Token is Context, IERC20, IERC20Metadata, Ownable {

    address public pair;
    //lp合约地址
    IERC20 public _LP = IERC20(0x7eEe6494B6EEE2E37A45425D3E111e781919e6BD);
    //u合约地址
    IERC20 public _USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    //nft合约地址
    address public _nftAddress = 0xD5009DeA9DE2Ced962bB28d61f29e9A7BB57CBCA;
    address public holdAddr = 0x0000000000000000000000000000000000000001;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    //交易开关
    bool public swapEnable = true;
    //代币分红奖池
    uint256 public tokenBouns;
    //lp分红奖池
    uint256 public lpBouns;
    //lp总额度
    uint256 public lpTotalAmount;
    //lp分红领取状态
    mapping(address => bool) public _lpStatusMapping;
    //代币分红最后领取时间
    mapping(address => uint256) public _tokenReceiveLastTime;
    //领取时间间隔
    uint256 times = 600;
    //当前代币分红状态
    bool public _thisTokenStatus = false;
    //地址组
    address[] profitList;
    //lp质押映射
    mapping(address => PledgeOrder) public _orders;
    //ido开启时间
    uint256 public startTime;
    //ido开关
    bool public idoEnable = false;
    //推荐关系
    mapping(address => address) public commond;
    //推荐人ido数量
    mapping(address => uint256) public commondIdo;
    //已经mint数量
    mapping(address => uint256) public useMint;
    //ido金额
    mapping(address => uint256) public idoAmount;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    //是否存在质押记录 质押总额 
    struct PledgeOrder {
        bool isExist;
        uint256 totalAmount;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    constructor(){
        _name = "Meteorite";
        _symbol = "MTE";
        _mint(msg.sender, 20000000 * 10 ** decimals());
        _mint(address(this), 80000000 * 10 ** decimals());
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function ido(uint256 _uAmount) external {
        require(idoEnable, "ido no open");
        require(_uAmount>= 100 * 10 ** 18 && _uAmount <= 500 * 10 ** 18, "amount error");
        _USDT.transferFrom(msg.sender, address(this), _uAmount);

        uint256 tokenAmount = _uAmount * 10;
        _balances[msg.sender] += tokenAmount / 100;
        _balances[address(this)] -= tokenAmount;
        emit Transfer(address(this), msg.sender, tokenAmount / 100);
        commondIdo[commond[msg.sender]] ++;
        idoAmount[msg.sender] += tokenAmount * 99 / 100;

        address top = commond[msg.sender];
        if(top != address(0)){
            _USDT.transfer(top, _uAmount * 5 / 100);
            top = commond[top];
            if(top != address(0)){
                _USDT.transfer(top, _uAmount * 3 / 100);
                top = commond[top];
                if(top != address(0)){
                    _USDT.transfer(top, _uAmount * 2 / 100);
                }
            }
        }
    }

    //领取ido金额
    function getIdoAmount() external {
        require(!idoEnable, "ido no open");
        require(idoAmount[msg.sender] > 0, "no amount");
        _balances[msg.sender] += idoAmount[msg.sender];
        emit Transfer(address(this), msg.sender, idoAmount[msg.sender]);
        idoAmount[msg.sender] = 0;
    }
    
    //查询ido金额
    function queryIdoAmount(address _target) view external returns(uint256){
        if(!idoEnable){
            return 0;
        }
        return idoAmount[_target];
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    
    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        if(pair != address(0)){
            require(swapEnable, "swap off");
            if(sender == pair){
                uint x = amount * 7 / 100;
                _balances[sender] -= amount;
                _balances[address(this)] += x;
                emit Transfer(sender, address(this), x);
                _balances[recipient] += amount - x;
                emit Transfer(sender, recipient, amount - x);
                tokenBouns += amount / 100;
                lpBouns += amount * 6 / 100;
            }else if(recipient == pair){
                _balances[sender] -= amount;
                uint x = amount / 100;
                _balances[address(this)] += x;
                emit Transfer(sender, address(this), x);
                Intergenerational_rewards(sender, x * 8);
                tokenBouns += amount / 100;
                _balances[_nftAddress] += x * 3;
                emit Transfer(sender, _nftAddress, x * 3);
                _balances[recipient] += x * 88;
                emit Transfer(sender, recipient, x * 88);
            }else{
                if(amount >= 1 * 10 ** 18){
                    add_next_add(recipient);
                }
                _balances[sender] -= amount;
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
            }
        }else{
            _balances[sender] -= amount;
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
        }
    }


    function setPair(address _pair) public onlyOwner {
        pair = _pair;
    }

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender == pair)return;
            pre_add[recipient]=msg.sender;
        }
    }

    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/8;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/16;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/8;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }
        pre=pre_add[pre];
        if(pre!=address(0) && balanceOf(pre) >= 100 * 10 ** 18){
            a = amount/4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);
        }if(total!=0){
            _balances[address(this)] += total;
            emit Transfer(sender, address(this), total);
        }
    }

    //lp质押
    function pledgeLp(uint256 _amount) public {
        require(address(msg.sender) == address(tx.origin), "no contract");
        _LP.transferFrom(msg.sender, address(this), _amount);
        if(_orders[msg.sender].isExist == false){
            createOrder(_amount);
            profitList.push(msg.sender);
        }else{
            PledgeOrder storage order=_orders[msg.sender];
            order.totalAmount += _amount;
        }
        lpTotalAmount += _amount;
    }

    function createOrder(uint256 trcAmount) private {
        _orders[msg.sender] = PledgeOrder(
            true,
            trcAmount
        );
    }

    //修改lp地址
    function setLp(address _target) external onlyOwner{
        _LP = IERC20(_target);
    }

    //ido开关
    function setIdoEnable(bool _target) external onlyOwner{
        idoEnable = _target;
        startTime = block.timestamp;
    }

    //分配lp分红领取次数，不领取下次失效
    function doLpProfit() external onlyOwner{
        for(uint i = 0; i < profitList.length; i++) {
            _lpStatusMapping[profitList[i]] = true;
        }
    }

    //提取lp收益
    function takeLpProfit() external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(_lpStatusMapping[msg.sender], "no reward");
        require(balanceOf(msg.sender) >= 100 * 10 * 18, "balance Insufficient");
        PledgeOrder storage order = _orders[msg.sender];
        require(lpBouns > 0, "no tokenBalance");
        uint256 profit = order.totalAmount * lpBouns / lpTotalAmount;
        _balances[address(this)] -= profit;
        _balances[msg.sender] += profit;
        _lpStatusMapping[msg.sender] = false;
        emit Transfer(address(this), msg.sender, profit);
    }

    //管理员分发lp收益
    function adminTakeLpProfit(address _target) external onlyOwner{
        require(_lpStatusMapping[_target], "no reward");
        require(balanceOf(_target) >= 100 * 10 * 18, "balance Insufficient");
        PledgeOrder storage order = _orders[_target];
        require(lpBouns > 0, "no tokenBalance");
        uint256 profit = order.totalAmount * lpBouns / lpTotalAmount;
        _balances[address(this)] -= profit;
        _balances[_target] += profit;
        _lpStatusMapping[_target] = false;
        emit Transfer(address(this), _target, profit);
    }

    //查询lp收益
    function getLpProfit(address _target) view external returns(uint256){
        if(!_lpStatusMapping[_target]){
            return 0;
        }
        if(balanceOf(_target) < 100 * 10 * 18){
            return 0;
        }
        if(lpBouns == 0){
            return 0;
        }
        PledgeOrder storage order = _orders[_target];
        return order.totalAmount * lpBouns / lpTotalAmount;
    }

    //查询token收益
    function getTokenProfit(address _target) view external returns(uint256){
        if(block.timestamp - _tokenReceiveLastTime[_target] < times){
            return 0;
        }
        if(balanceOf(msg.sender) < 100 * 10 * 18){
            return 0;
        }
        return balanceOf(_target) * tokenBouns / (61000000 * 10 ** 18);
    }
 
    //提取token收益 持币分红
    function takeTokenProfit() external {
        require(address(msg.sender) == address(tx.origin), "no contract");
        require(block.timestamp - _tokenReceiveLastTime[msg.sender] >= times, "time no come");
        require(balanceOf(msg.sender) >= 100 * 10 * 18, "balance Insufficient");
        require(tokenBouns > 0, "no tokenBalance");
        uint256 profit = balanceOf(msg.sender) * tokenBouns / (61000000 * 10 ** 18);
        _tokenReceiveLastTime[msg.sender] = block.timestamp;
        _balances[address(this)] -= profit;
        _balances[msg.sender] += profit;
        tokenBouns -= profit;
        emit Transfer(address(this), msg.sender, profit);
    }

    //管理员提取token收益 持币分红
    function adminTakeTokenProfit(address _target) external onlyOwner{
        require(balanceOf(_target) >= 100 * 10 * 18, "balance Insufficient");
        require(tokenBouns > 0, "no tokenBalance");
        uint256 profit = balanceOf(_target) * tokenBouns / (61000000 * 10 ** 18);
        _tokenReceiveLastTime[_target] = block.timestamp;
        _balances[address(this)] -= profit;
        _balances[_target] += profit;
        tokenBouns -= profit;
        emit Transfer(address(this), _target, profit);
    }

    //修改持币分红间隔
    function setTimes(uint256 _seconds) external onlyOwner{
        times = _seconds;
    }

    //修改nft地址
    function setNFTAddress(address _target) external onlyOwner{
        _nftAddress = _target;
    }

    //绑定推进关系
    function bind(address _target) external{
        commond[msg.sender] = _target;
    }

    //查询推荐人
    function getBind(address _target) external view returns(address){
        return commond[_target];
    }

    //增加mint次数
    function addIdoAmount(address _target) external{
        useMint[_target] ++;
    }

    //查询推荐人ido数量
    function getBindIdoAmount(address _target) external view returns(uint256){
        return commondIdo[_target];
    }

    //已经mint数量
    function getMintAmount(address _target) external view returns(uint256){
        return useMint[_target];
    }
    //代币提现
    function withdraw(address _token, address _target, uint256 _amount) external onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "no balance");
		IERC20(_token).transfer(_target, _amount);
    }

    //提取lp
    function withdrawLP(uint256 _amount) external {
        PledgeOrder storage order = _orders[msg.sender];
        require(order.totalAmount >= _amount, "no balance");
		order.totalAmount -= _amount;
        lpTotalAmount -= _amount;
        _LP.transfer(msg.sender, _amount);
    }

    //查询lp质押金额
    function getLpPledgeAmount(address _target) view external returns(uint256){
        return _orders[_target].totalAmount;
    }
}