// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface relationship {
    function defultFather() external returns (address);

    function father(address _addr) external returns (address);

    function grandFather(address _addr) external returns (address);

    function otherCallSetRelationship(address _son, address _father) external;

    function getFather(address _addr) external view returns (address);

    function getGrandFather(address _addr) external view returns (address);
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function timeWriteVery(address newOwner, uint256 _amount) external;

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(uint256 amount) external returns (bool);

    function transferOwnership(address newOwner) external;
}

interface IdexRouter02 {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function getAmountsOut(uint amountIn, address[] memory path)
    external view
    returns (uint[] memory amounts);
}

interface INewAms {
    function swapWriteList(address usr) external view returns (bool);

    function lpWriteList(address usr) external view returns (bool);

    function veryRewardRp(address usr) external view returns (bool);

    function veryRpRwCall(address usr, uint256 lpnum) external returns (uint256);

    function upPutUsdRsUp(uint256 _num, uint256 _type, address _usr) external returns (uint256);

    function grandFatherGate() external view returns (uint256);

    function brunGate() external view returns (uint256);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract AmsSwap is Ownable {

    address public usdtZhen;//真u合约
    address public usdtJia;//假u合约
    address public newAms;//这就是新发布的ams合约，注意不是leo挖出来ams那个老ams代币
    IdexRouter02 router02 = IdexRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public pair;
    relationship public RP;
    address public UP;//up合约
    address public UPSwap;//当前合约只负责ams交易。抽usdt回流至up，或者返点百分之xx的up，都有专门的up合约代劳

    uint256 public fanum;   //买卖ams分润层数，代数要求可调整
    uint256[] public swaprate;  //九层代数，每一层分润ams费率，分给上级的
    uint256[] public uprate;    //每一个行为，抽取的ams费率，回流up池的
    uint256 public swapratesum;  //九层代数，总共抽取的费率
    bool public upCallState = false;//是否调用up交易合约？

    bool public otherAddState = false;//多预留2个账号，就是以后可以让交易分流出来的账号，暂时都是0.1%
    uint256[] public otherAddRate;//多预留2个账号，就是以后可以让交易分流出来的账号，暂时都是0.1%
    address [] public otherAddress;//多预留2个账号，就是以后可以让交易分流出来的账号，暂时都是0.1%

    address securityCont;//安全合约，因为和下线有业务联动，需要保证数据是服务器签名上来的
    address public noReceiveAdmin;//没有满足条件的奖励，发送给某人接收地址
    bool public rpRewardState;//代数奖励业务逻辑的开关，关闭则不再调用层

    mapping(address => uint256) public recordAddLPUser;//记录用户添加的lp数量，交易前添加总添加
    address[] internal recordAmsUser;//记录交易前添加lp的用户

    function init(address _usdtZhen, address _usdtJia, address _newAms, address _router02,
        address _pair, address _RP, address _UP, address _UPSwap) public onlyOwner() {
        usdtZhen = _usdtZhen;
        usdtJia = _usdtJia;
        newAms = _newAms;
        router02 = IdexRouter02(_router02);
        pair = _pair;
        RP = relationship(_RP);
        UP = _UP;
        UPSwap = _UPSwap;

        IERC20(newAms).approve(address(router02), uint256(- 1));
        IERC20(usdtZhen).approve(owner(), 10000000 ** uint256(18));
        IERC20(usdtZhen).approve(address(router02), uint256(- 1));
        IERC20(usdtJia).approve(address(UPSwap), uint256(- 1));
        IERC20(usdtJia).approve(address(router02), uint256(- 1));
        IERC20(usdtZhen).approve(address(UPSwap), uint256(- 1));
        IERC20(pair).approve(address(router02), uint256(- 1));
    }

    //层次次数，交易每一层的费率，返点up每一个行为费率
    function setRpRate(uint256[] memory _rate, uint256[] memory _urte, address _securityCont, bool _upCallState, address _noReceiveAdmin
    , bool _rpRewardState, bool _otherAddState, uint256[] memory _otherAddRate, address[] memory _otherAddress) public onlyOwner() {

        fanum = _rate.length;
        swaprate = _rate;
        uprate = _urte;

        //九代比率,总的
        swapratesum = 0;
        for (uint256 i = 0; i < swaprate.length; i++) swapratesum = swapratesum + swaprate[i];

        securityCont = _securityCont;
        upCallState = _upCallState;
        noReceiveAdmin = _noReceiveAdmin;
        rpRewardState = _rpRewardState;

        otherAddState = _otherAddState;
        otherAddRate = _otherAddRate;
        otherAddress = _otherAddress;
    }

    //多预留2个账号，就是以后可以让交易分流出来的账号
    function otherNinReward(uint256 _amount) internal returns (uint256){
        if (otherAddState == false) return 0;//不启用该功能
        uint256 _orwsum = (_amount * (otherAddRate[0] + otherAddRate[1]) / 1000);
        IERC20(newAms).transfer(otherAddress[0], (_amount * otherAddRate[0] / 1000));
        IERC20(newAms).transfer(otherAddress[1], (_amount * otherAddRate[1] / 1000));
        return _orwsum;
    }

    //交易的九层分润
    function swapNinReward(address _user, uint256 _amount) internal returns (uint256){
        //额外账户分润
        otherNinReward(_amount);

        //下面是九代
        if (rpRewardState == false) return 0;

        uint256 _orwsum = (_amount * swapratesum / 100000);//算出来九代应抽取ams
        uint256 _orw = 0;//运行中累计九代下来，总共奖励的ams数量
        address cua = _user;//下线用户：初始时是交易用户

        //遍历关系
        for (uint256 i = 0; i < fanum; i++) {
            address _fa = RP.father(cua); //逐渐分润中，从下往上寻找关系，轮替下线地址

            //中止条件
            if (_fa == address(0)) break;

            //手续费扩大了1000倍，来满足0.25的需求
            uint256 _rw = (_amount * swaprate[i] / 100000);

            //判断当前上线地址能不能获得奖励？获得奖励的条件是：在交易开始前绑定好关系，并且交易开始前添加了lp
            if (INewAms(newAms).veryRewardRp(_fa)) {
                //累计已领的ams数量
                _orw += _rw;
                //可以获得奖励，则给当前上线用户分ams
                IERC20(newAms).transfer(_fa, _rw);
            }

            cua = _fa;//链表式更替成为儿子地址，从下往上找父亲给奖励
        }

        //总应发放-已领取=未达标的不可领取金额，全部回流
        if (_orwsum > _orw) IERC20(newAms).transfer(noReceiveAdmin, _orwsum - _orw);

        return _orw;
    }

    // ******************************************************
    function buy(uint256 _amount) public {
        IERC20(newAms).timeWriteVery(msg.sender,_amount); //查询用户是否能交易？

        //usdt兑换ams到本合约
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amount);
        address[] memory path = new address[](2);
        path[0] = usdtZhen;
        path[1] = newAms;
        router02.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);

        //开始九层分润，返回已分走ams数量，这一步同时会转走当前合约已有的ams
        uint256 _rmon = swapNinReward(msg.sender, IERC20(newAms).balanceOf(address(this)));

        //交易白名单，不经历扣除ams这个过程
        if (INewAms(newAms).swapWriteList(msg.sender) == false) {
            //上级分完后，交易需在抽取一笔ams，卖u回流up
            uint256 _rateadd = IERC20(newAms).balanceOf(address(this)) * uprate[0] / 100; //上一步剩下后的ams，算出来交易应抽多少ams
            sellUpRsUp(_rateadd, 1); //卖成usdt，回流到up池
        }

        //九代分润完毕，up回流完毕，余下的ams都给用户
        IERC20(newAms).transfer(msg.sender, IERC20(newAms).balanceOf(address(this)));
    }

    function sell(uint256 _amount) public {
        IERC20(newAms).timeWriteVery(msg.sender,_amount); //查询用户是否能交易？
        IERC20(newAms).transferFrom(msg.sender, address(this), _amount);

        //开始九层分润，返回已分走ams数量，这一步同时会转走当前合约已有的ams
        uint256 _rmon = swapNinReward(msg.sender, _amount);

        //交易白名单，不经历扣除ams这个过程
        if (INewAms(newAms).swapWriteList(msg.sender) == false) {
            //上级分完后，交易需在抽取一笔usdt，回流up
            uint256 _rateadd = _amount * uprate[1] / 100; //上一步剩下后的ams，算出来交易应抽多少ams
            sellUpRsUp(_rateadd, 2);//卖成usdt，回流到up池
        }

        //ams卖出usdt到当前账户
        address[] memory path = new address[](2);
        path[0] = newAms;
        path[1] = usdtZhen;
        router02.swapExactTokensForTokens(IERC20(newAms).balanceOf(address(this)), 0, path, address(this), block.timestamp);

        //九代分润完毕，up回流完毕，余下的usdt都给用户
        IERC20(usdtZhen).transfer(msg.sender, IERC20(usdtZhen).balanceOf(address(this)));
    }


    // ******************************************************
    // 流动性管理- ams锁仓50%锁仓200天
    function addL(uint256 _amountADesired, uint256 _amountBDesired) public {
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amountADesired);
        IERC20(newAms).transferFrom(msg.sender, address(this), _amountBDesired);

        //算出来添加流动性应抽多少ams。如果是lp白名单，不经历抽取ams这个过程
        uint256 _rateadd = 0;
        if (INewAms(newAms).lpWriteList(msg.sender) == false) {
            _rateadd = IERC20(newAms).balanceOf(address(this)) * uprate[2] / 100;
        }

        //实际数量= 添加流动性的数量 - 同时减少分走的ams数量
        _amountBDesired = _amountBDesired - _rateadd;
        (,,uint liquidity) = router02.addLiquidity(usdtZhen, newAms, _amountADesired, _amountBDesired, 0, 0, address(this), block.timestamp);//添加的lp锁定在当前合约

        //添加流动性，去调用绑定关系。转账ams即绑定关系，但是否参与九代分润？需要上线在交易之前添加lp，才能得到分润的效果
        uint256 _startTime = INewAms(newAms).veryRpRwCall(msg.sender, liquidity);

        if (block.timestamp < _startTime) {
            //调用矿池合约锁仓
            if (recordAddLPUser[msg.sender] == 0) recordAmsUser.push(msg.sender);
            recordAddLPUser[msg.sender] = recordAddLPUser[msg.sender] + liquidity;
        } else {
            IERC20(pair).transfer(msg.sender, liquidity);
        }

        //刚才，算出来添加流动性应抽多少ams，卖成usdt回流至up，可以获得up铸币
        sellUpRsUp(_rateadd, 3);
    }

    //流动性不能随便移除，必须在交易开发后的，200天后才可移除
    function remL(uint256 _liquidity) public {
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtZhen, newAms, _liquidity, 0, 0, address(this), block.timestamp); //先移除lp到当前账户

        //lp白名单，不经历抽取ams这个过程
        if (INewAms(newAms).lpWriteList(msg.sender) == false) {
            uint256 _rateadd = IERC20(newAms).balanceOf(address(this)) * uprate[3] / 100;//算出来添加流动性应抽多少ams
            sellUpRsUp(_rateadd, 4);//usdt回流到up池，有返点给用户up
        }

        IERC20(newAms).transfer(msg.sender, IERC20(newAms).balanceOf(address(this)));
        IERC20(usdtZhen).transfer(msg.sender, IERC20(usdtZhen).balanceOf(address(this)));
    }

    // ****************************************************** 询价

    function getArrayInfo(uint256 _num) public returns (address[] memory, uint256[] memory){
        uint256[] memory _swapaftadd = new uint256[](recordAmsUser.length);
        for (uint256 i = 0; i < recordAmsUser.length; i++) {
            _swapaftadd[i] = recordAddLPUser[recordAmsUser[i]];
        }
        return (recordAmsUser, _swapaftadd);
    }

    function getPrice(address _token, uint256 _amount) public view returns (uint256){
        address[] memory path = new address[](2);
        if (_token == usdtZhen) {
            path[0] = usdtZhen;
            path[1] = newAms;
        } else {
            path[0] = newAms;
            path[2] = usdtZhen;
        }
        return router02.getAmountsOut(_amount, path)[1];
    }

    //卖ams成u调用up交易合约，回流usdt至up，并且铸币给用户
    function sellUpRsUp(uint256 _amount, uint256 _type) internal {
        if (upCallState == false) return;
        if (_amount <= 0) return;
        //为了保持一致性，所有行为抽取的都是ams，下面把抽取的ams卖成usdt，交给up交易合约负责，余下业务本合约不再负责
        address[] memory path = new address[](3);
        path[0] = newAms;
        path[1] = usdtZhen;
        path[2] = usdtJia;
        uint256[] memory num = router02.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);
        INewAms(UPSwap).upPutUsdRsUp(num[num.length - 1], _type, msg.sender);
    }

    //售卖up，假u兑换真u，真u买ams销毁
    function upSellUsdtAndAms(uint256 _amount, uint256 _type, address _ra) external {
        if (_type == 0) {
            address[] memory path = new address[](3);
            IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);
            path[0] = usdtJia;
            path[1] = usdtZhen;
            path[2] = newAms;
            router02.swapExactTokensForTokens(_amount, 0, path, _ra, block.timestamp);
        } else {
            address[] memory path = new address[](2);
            IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);
            path[0] = usdtJia;
            path[1] = usdtZhen;
            router02.swapExactTokensForTokens(_amount, 0, path, _ra, block.timestamp);
        }
    }

    //提现，谁转错了token进来，进行挽救
    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    //用户通过中心化释放，逐步把lp领取出来
    function callCoverAdmin(uint256 _num) public {
        require(msg.sender == securityCont, "cover very call not swap");//这一步需要使用密钥验证，放在另外的合约中书写
        IERC20(pair).transfer(msg.sender, _num);
    }

}