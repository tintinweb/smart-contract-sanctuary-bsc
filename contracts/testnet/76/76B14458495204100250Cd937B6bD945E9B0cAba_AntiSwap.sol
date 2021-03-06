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

    //???u???token???lp
    address public pair;
    //???u??????u???lp
    address public pair2;
    address public defaultAdd; //???????????????????????????????????????
    relationship public RP;

    address public fundPoolAdd; //??????????????????????????????
    uint256 public fundPoolRate; //??????????????????????????????
    uint256 public sixGenSumRate; //????????????,??????,??????10???
    uint256[] public sixGenRate; //????????????,??????,??????100???

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

        //??????????????????????????????????????????????????????????????????????????????????????????gg???
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

    //?????????????????????????????????????????????????????????
    function rpSixAwardPub(uint256 _amount, address _to) internal returns (uint256){
        uint256 _trueAmount = _amount * (100000 - (sixGenSumRate + fundPoolRate)) / 100000; //????????????????????????????????????????????????????????????????????????
        rpSixAward(_to, _amount); //????????????????????????
        IERC20(anti).transfer(fundPoolAdd, _amount * fundPoolRate / 100000);//??????????????????
        return _trueAmount;
    }

    function rpSixAward(address _user, uint256 _amount) internal returns (uint256){
        uint256 orw = 0;        //?????????????????????
        address cua = _user;    //???????????????????????????????????????????????????

        //????????????????????????????????????????????????
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            //????????????????????????????????????????????????????????????????????????????????????????????????????????????
            if (_fa == address(0)) {
                //???????????????????????????????????????????????????-?????????????????????????????????????????????????????????????????????????????????
                uint256 defaultAll = ((_amount * sixGenSumRate / 100000) - orw);
                IERC20(anti).transfer(defaultAdd, defaultAll);
                break;
            }

            //????????????????????????????????????????????????????????????????????????????????????????????????????????????10???????????????0.X???????????????????????????
            uint256 _rw = (_amount * sixGenRate[i] / 100000);
            IERC20(anti).transfer(_fa, _rw);

            //???????????????????????????????????????????????????????????????????????????????????????????????????
            cua = _fa;
            orw += _rw;
        }

        return orw;
    }

    // ******************************************************
    //???u???token
    function buy(uint256 _amount) public {
        require(writeList[msg.sender],"no swap role");
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amount);

        //????????????token
        address[] memory path = new address[](3);
        path[0] = usdtZhen;
        path[1] = usdtJia;
        path[2] = anti;
        uint256[] memory amountSwap = router02.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);

        uint256 bf = amountSwap[amountSwap.length - 1];//??????token??????
        uint256 bk = rpSixAwardPub(bf, msg.sender);//??????????????????
        IERC20(anti).transfer(msg.sender, bf - bk);//????????????????????????????????????????????????
    }

    function sell(uint256 _amount) public {
        require(writeList[msg.sender],"no swap role");
        IERC20(anti).transferFrom(msg.sender, address(this), _amount);

        _amount = rpSixAwardPub(_amount, msg.sender);//????????????????????????????????????????????????

        address[] memory path = new address[](3);
        path[0] = anti;
        path[1] = usdtJia;
        path[2] = usdtZhen;
        router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // ******************************************************
    //???u???token
    function buy2(uint256 _amount) public {
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = anti;

        uint256[] memory amountSwap = router02.swapExactTokensForTokens(_amount, 0, path, address(this), block.timestamp);

        uint256 bf = amountSwap[amountSwap.length - 1];//??????token??????
        uint256 bk = rpSixAwardPub(bf, msg.sender);//??????????????????
        IERC20(anti).transfer(msg.sender, bf - bk);//????????????????????????????????????????????????
    }

    function sell2(uint256 _amount) public {
        IERC20(anti).transferFrom(msg.sender, address(this), _amount);

        _amount = rpSixAwardPub(_amount, msg.sender);//????????????????????????????????????????????????

        address[] memory path = new address[](2);
        path[0] = anti;
        path[1] = usdtJia;

        router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // ******************************************************
    //???u??????u
    function buy3(uint256 _amount) public {
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtZhen;
        path[1] = usdtJia;

        uint256[] memory amountSwap = router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    function sell3(uint256 _amount) public {
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amount);

        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = usdtZhen;

        router02.swapExactTokensForTokens(_amount, 0, path, msg.sender, block.timestamp);
    }

    // ******************************************************
    //???u??????u????????????????????????????????????????????????????????????????????????????????????????????????
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
    // ???????????????- ???u???token
    function addL(uint256 _amountADesired, uint256 _amountBDesired) public {
        //???????????????u?????????u????????????????????????u
        buy3(_amountADesired, address(this));
        IERC20(anti).transferFrom(msg.sender, address(this), _amountBDesired);

        router02.addLiquidity(usdtJia, anti, IERC20(usdtJia).balanceOf(address(this)), _amountBDesired, 0, 0, msg.sender, block.timestamp);
    }

    function remL(uint256 _liquidity) public {
        //????????????????????????lp???????????????u???token?????????lp???????????????????????????????????????u???token
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtJia, anti, _liquidity, 0, 0, address(this), block.timestamp);

        //????????????u?????????u
        address[] memory path = new address[](2);
        path[0] = usdtJia;
        path[1] = usdtZhen;
        router02.swapExactTokensForTokens(IERC20(usdtJia).balanceOf(address(this)), 0, path, address(this), block.timestamp);

        //????????????
        IERC20(usdtZhen).transfer(msg.sender, IERC20(usdtZhen).balanceOf(address(this)));
        IERC20(anti).transfer(msg.sender, IERC20(anti).balanceOf(address(this)));
    }

    // ???????????????- token??????u???????????????????????????u?????????u????????????????????????2????????????????????????????????????????????????u????????????????????????2???????????????????????????2???u???token????????????(???????????????u???token?????????)
    function addL2(uint256 _amountADesired, uint256 _amountBDesired) public {
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amountADesired);
        IERC20(anti).transferFrom(msg.sender, address(this), _amountBDesired);
        router02.addLiquidity(usdtJia, anti, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);
    }

    function remL2(uint256 _liquidity) public {
        IERC20(pair).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtJia, anti, _liquidity, 0, 0, msg.sender, block.timestamp);
    }

    // ???????????????- ???u??????u????????????????????????1????????????????????????????????????????????????
    function addL3(uint256 _amountADesired, uint256 _amountBDesired) public {
        IERC20(usdtZhen).transferFrom(msg.sender, address(this), _amountADesired);
        IERC20(usdtJia).transferFrom(msg.sender, address(this), _amountBDesired);
        router02.addLiquidity(usdtZhen, usdtJia, _amountADesired, _amountBDesired, 0, 0, msg.sender, block.timestamp);
    }

    function remL3(uint256 _liquidity) public {
        IERC20(pair2).transferFrom(msg.sender, address(this), _liquidity);
        router02.removeLiquidity(usdtJia, usdtZhen, _liquidity, 0, 0, msg.sender, block.timestamp);
    }

    // ****************************************************** ??????

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

    // ****************************************************** ?????????????????????lp

    function getLp(address fa, address tokenA, address tokenB) public view returns (address pair){return IusdtZhen(fa).getPair(tokenA, tokenB);}

}