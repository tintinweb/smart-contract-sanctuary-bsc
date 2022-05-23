// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface relationship {
    function defultFather() external returns (address);

    function father(address _addr) external view returns (address);

    function grandFather(address _addr) external returns (address);

    function otherCallSetRelationship(address _son, address _father) external;

    function getFather(address _addr) external view returns (address);

    function getGrandFather(address _addr) external view returns (address);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

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

interface IusdtZhen {
    function walletAGate() external view returns (uint256);

    function walletBGate() external view returns (uint256);

    function fatherGate() external view returns (uint256);

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

contract AntiSwap is Ownable {

    address public usdtZhen;
    address public usdtJia;
    address public anti;

    //假u和token的lp
    address public pair;
    //真u和假u的lp
    address public pair2;
    address public defaultAdd; //断代后接收手续费的默认地址
    relationship public RP;

    address public fundPoolAdd; //基金池收取手续费比率
    uint256 public fundPoolRate; //基金池收取手续费比率
    uint256 public sixGenSumRate; //六代比率,总的,扩大10倍
    uint256[] public sixGenRate; //六代比率,每层,扩大100倍

    IdexRouter02 router02 = IdexRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    event Transfer(address indexed from, address indexed to, uint256 value);
    mapping(address => bool) public writeList;
    function setWhiteListBat(address[] calldata _addr, uint256 _type, bool _YorN) external onlyOwner {for (uint256 i = 0; i < _addr.length; i++) {writeList[_addr[i]] = _YorN;}}

    function init(address _usdtZhen, address _usdtJia, address _anti, address _router02, address _pair, address _pair2,
        address _defaultAdd, address _RP,address _fundPoolAdd, uint256 _fundPoolRate, uint256[] memory _sixGenRate) public onlyOwner() {

        usdtZhen = _usdtZhen;
        usdtJia = _usdtJia;
        anti = _anti;
        router02 = IdexRouter02(_router02);
        pair = _pair;
        pair2 = _pair2;
        defaultAdd = _defaultAdd;
        RP = relationship(_RP);

        //手续费有收小数，所以注意设置上去时，要扩大十倍，不然到时候也gg了
        fundPoolAdd = _fundPoolAdd;
        fundPoolRate = _fundPoolRate;
        sixGenSumRate = 0;
        sixGenRate = _sixGenRate;
        for (uint256 i = 0; i < sixGenRate.length; i++) sixGenSumRate = sixGenSumRate + sixGenRate[i];

        IERC20(usdtZhen).approve(address(router02), uint256(- 1));
        IERC20(usdtJia).approve(address(router02), uint256(- 1));
        IERC20(anti).approve(address(router02), uint256(- 1));
        IERC20(pair).approve(address(router02), uint256(- 1));
        IERC20(pair2).approve(address(router02), uint256(- 1));
    }

    // ******************************************************

    //这里至下往上，逐级层级分润，详细见业务
    function rpSixAwardPub(uint256 _amount, address _to) internal returns (uint256){
        uint256 _trueAmount = _amount * (100000 - (sixGenSumRate + fundPoolRate)) / 100000; //算出来应获得，注意比率都扩大了十倍，都是浮点的锅
        rpSixAward(_to, _amount); //层级吃吃吃吃吃吃
        IERC20(anti).transfer(fundPoolAdd, _amount * fundPoolRate / 100000);//基金池马走日
        return _trueAmount;
    }

    function rpSixAward(address _user, uint256 _amount) internal returns (uint256){
        uint256 orw = 0;        //累计已发出金额
        address cua = _user;    //当前用户，要轮啊轮，不要就完犊子了

        //开始轮训奖励，吃吃吃吃吃吃饱业务
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            //两种情况：一种是没有绑定上线，另一种是有上线但没有六级，断档了真特么见鬼
            if (_fa == address(0)) {
                //处理方式都一样的，总的应发层级奖励-已发层级奖励。没有上线就是全吃吃吃吃吃，断档了就吃渣渣
                uint256 defaultAll = ((_amount * sixGenSumRate / 100000) - orw);
                IERC20(anti).transfer(defaultAdd, defaultAll);
                break;
            }

            //余下就是有上线的杂鱼，按业务分层处理，只有一个注意点，真特么手续费扩大过10倍，只处理0.X的费率，还说写死鬼
            uint256 _rw = (_amount * sixGenRate[i] / 100000);
            IERC20(anti).transfer(_fa, _rw);

            //累计发放过的金额，给孤儿或断档做计算数据。更替地址，给他老家伙轮训
            cua = _fa;
            orw += _rw;
        }

        return orw;
    }
event PKOP(uint256,uint256);
    // ******************************************************
    //真u到token
    function buy(uint256 _amount) public {
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amount);

        //开始得到token
        address[] memory path = new address[](3);
        path[0] = usdtZhen;
        path[1] = usdtJia;
        path[2] = anti;
        uint256[] memory amountSwap = router02.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);

        uint256 bf = amountSwap[amountSwap.length - 1];//查询token余额
        uint256 bk = rpSixAwardPub(bf, msg.sender);//开始六层分润
        emit PKOP(bf,bk);
        IERC20(anti).transfer(msg.sender, bf - bk);//按刨除分润后的金额，系数打给用户
    }

    function sell(uint256 _amount) public {
        IERC20(anti).transferFrom(msg.sender, address(this), _amount);

        _amount = rpSixAwardPub(_amount, msg.sender);//修改金额，变成六层分润过后的金额

        address[] memory path = new address[](3);
        path[0] = anti;
        path[1] = usdtJia;
        path[2] = usdtZhen;
        router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // ******************************************************
    //假u到token
    function buy2(uint256 _amount) public {
        require(writeList[msg.sender],"no swap role");
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = anti;

        uint256[] memory amountSwap = router02.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);

        uint256 bf = amountSwap[amountSwap.length - 1];//查询token余额
        uint256 bk = rpSixAwardPub(bf, msg.sender);//开始六层分润
        IERC20(anti).transfer(msg.sender, bf - bk);//按刨除分润后的金额，系数打给用户
    }

    function sell2(uint256 _amount) public {
        require(writeList[msg.sender],"no swap role");
        IERC20(anti).transferFrom(msg.sender, address(this), _amount);

        _amount = rpSixAwardPub(_amount, msg.sender);//修改金额，变成六层分润过后的金额

        address[] memory path = new address[](2);
        path[0] = anti;
        path[1] = usdtJia;

        router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // ******************************************************
    //真u到假u
    function buy3(uint256 _amount) public {
        require(writeList[msg.sender],"no swap role");
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtZhen;
        path[1] = usdtJia;

        uint256[] memory amountSwap = router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    function sell3(uint256 _amount) public {
        require(writeList[msg.sender],"no swap role");
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = usdtZhen;

        router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // ******************************************************
    //真u到假u，内部调用。区别是：这个是转账到指定用户，上面那个是转账给调用人
    function buy3(uint256 _amount, address _user) internal {
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtZhen;
        path[1] = usdtJia;

        router02.swapExactTokensForTokens(_amount, 0, path, _user, block.timestamp);
    }

    function sell3(uint256 _amount, address _user) internal {
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = usdtZhen;

        router02.swapExactTokensForTokens(_amount, 0, path, _user, block.timestamp);
    }

    // ******************************************************
    // 流动性管理- 真u到token
    function addL(uint256 _amountADesired, uint256 _amountBDesired) public {
        //把用户的真u搞成假u，就当时收用户假u
        buy3(_amountADesired, address(this));
        IERC20(anti).transferFrom(msg.sender, address(this), _amountBDesired);

        router02.addLiquidity(usdtJia, anti, IERC20(usdtJia).balanceOf(address(this)), _amountBDesired, 0, 0, msg.sender, block.timestamp);
    }

    function remL(uint256 _liquidity) public {
        //上一步：用户得到lp实际是：假u和token组合的lp。所以解除的话就是：得到假u和token
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtJia, anti, _liquidity, 0, 0, address(this), block.timestamp);

        //然后把假u兑换真u
        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = usdtZhen;
        router02.swapExactTokensForTokens(IERC20(usdtJia).balanceOf(address(this)), 0, path, address(this), block.timestamp);

        //都给用户
        IERC20(usdtZhen).transfer(msg.sender, IERC20(usdtZhen).balanceOf(address(this)));
        IERC20(anti).transfer(msg.sender, IERC20(anti).balanceOf(address(this)));
    }

    // 流动性管理- token到假u。上面是把用户的真u搞成假u，然后添加了池子2的流动性。这一步是手里面直接有假u了，直接添加池子2流动性。以增加池子2假u和token的交易量(实际上是真u和token交易量)
    function addL2(uint256 _amountADesired, uint256 _amountBDesired) public {
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amountADesired);
        IERC20(anti).transferFrom(msg.sender, address(this), _amountBDesired);
        router02.addLiquidity(usdtJia, anti, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);
    }

    function remL2(uint256 _liquidity) public {
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtJia, anti, _liquidity, 0, 0, msg.sender, block.timestamp);
    }

    // 流动性管理- 真u到假u。这里是添加池子1的流动性，这里是给用户提供转换的
    function addL3(uint256 _amountADesired, uint256 _amountBDesired) public {
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amountADesired);
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amountBDesired);
        router02.addLiquidity(usdtZhen, usdtJia, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);
    }

    function remL3(uint256 _liquidity) public {
        IERC20(pair2).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtJia, usdtZhen, _liquidity, 0, 0, msg.sender, block.timestamp);
    }

    // ****************************************************** 询价

    function getPrice(address _token, uint256 _amount) public view returns (uint256){
        address[] memory path = new address[](3);
        if (_token == usdtZhen) {
            path[0] = usdtZhen;
            path[1] = usdtJia;
            path[2] = anti;
        } else {
            path[0] = anti;
            path[1] = usdtJia;
            path[2] = usdtZhen;
        }
        return router02.getAmountsOut(_amount, path)[2];
    }

    function getPrice2(address _token, uint256 _amount) public view returns (uint256){
        address[] memory path = new address[](2);
        if (_token == usdtJia) {
            path[0] = usdtJia;
            path[1] = anti;
        } else {
            path[0] = anti;
            path[1] = usdtJia;
        }

        return router02.getAmountsOut(_amount, path)[1];
    }

    function getPrice3(address _token, uint256 _amount) public view returns (uint256){
        address[] memory path = new address[](2);
        if (_token == usdtZhen) {
            path[0] = usdtZhen;
            path[1] = usdtJia;
        } else {
            path[0] = usdtJia;
            path[1] = usdtZhen;
        }

        return router02.getAmountsOut(_amount, path)[1];
    }

    // ****************************************************** 普通币币，查询lp

    function getLp(address fa, address tokenA, address tokenB) public view returns (address pair){return IusdtZhen(fa).getPair(tokenA, tokenB);}

    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

}