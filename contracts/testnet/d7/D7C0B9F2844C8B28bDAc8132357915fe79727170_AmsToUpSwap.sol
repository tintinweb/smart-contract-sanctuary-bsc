// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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

interface INewAms {
    function mint(uint256 amount, address _urs) external returns (bool);

    function grandFatherGate() external view returns (uint256);

    function upSellUsdtAndAms(uint256, uint256, address) external;

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

contract AmsToUpSwap is Ownable {

    address public usdtJia;//真u地址
    address public UP;//up代币地址
    address public amsswap;//ams交易合约,可以调用本合约完成up业务

    uint256[] public upfan;//返点up的比率【卖ams，添加lp】
    uint256 public buyamsr;//售卖up时收取的usdt费率（目的是购买ams并且销毁）
    uint256 public huiliuams;//售卖up时回到到up池的usdt比率

    event UpPutUsdRsUp(uint256, uint256, uint256);

    //真u，假u，返点up比率，卖出up购买ams比率，卖出up回流至up比率
    function init(address _usdtJia, address _UP, address _amsswap,
        uint256[] memory _upfan, uint256 _buyamsr, uint256 _huiliuams) public onlyOwner() {
        usdtJia = _usdtJia;
        UP = _UP;
        amsswap = _amsswap;

        upfan = _upfan;
        buyamsr = _buyamsr;
        huiliuams = _huiliuams;
    }


    //初始价格：5美金1个up
    function getPrice(address token, uint256 _num) public view returns (uint256){
        uint256 amountA = IERC20(UP).totalSupply();//已流通的up数量
        uint256 amountB = IERC20(usdtJia).balanceOf(address(UP));//up池中的usdt数量

        //20 - 3
        uint256 price = 0;
        if (token == usdtJia) {
            //xx个usdt，可兑换xx个up？usdt->up = 3/20 = 0.15
            price = (amountA * _num) / amountB;
        } else {
            //xx个up，可兑换xx个usdt？up->usdt = 20/3 = 6.66
            //1up=5usdt -> 5 = 5*1 / 1 -> 初始就是5分usdt和1个up即可
            price = (amountB * _num) / amountA;
        }

        return price;
    }

    //假u流入up池，返点up。参数：假u的数量(已经售卖过后)，行为类型。假u变多up变多(铸币)
    function upPutUsdRsUp(uint256 _num, uint256 _type) external returns (uint256){
        uint256 _usdtnum = 0;
        require(amsswap == msg.sender, "call address not swap");
        IERC20(usdtJia).transferFrom(amsswap, address(this), _num);//up业务完成，抽取假u

        //购买ams和移除ams-usdt的lp，都不返还up
        if (_type == 1 || _type == 4) {
            return _usdtnum;
        }

        if (_type == 2) {
            //行为卖ams：把抽取的假u取2%铸造，等价up
            _usdtnum = _num * upfan[0] / 100;//例如10个假u，就是铸造等价取0.2个u(10的2%)的up币
        } else if (_type == 3) {
            //行为添加lp，把抽取的假u取4%铸造，等价up
            _usdtnum = _num * upfan[1] / 100;
        }

        //接上句话，得到0.2个u价值的up币数量，并且铸造up币给用户
        // 5u = 1up , 1u=0.2up (1/5) , 0.399239923992399 =
        uint256 up = getPrice(usdtJia, _usdtnum);
        INewAms(UP).mint(up, msg.sender);
        emit UpPutUsdRsUp(_usdtnum, _num, up);

        return up;
    }

    //售卖up代币，假u加少，up变少(销毁了)
    function sellUp(uint256 _amount) external {
        IERC20(UP).transferFrom(msg.sender, address(this), _amount);
        //例售卖10个up，得到10个up币价值的usdt数量
        uint256 usdtnum = getPrice(address(this), _amount);
        //如果up池内的usdt数量，低于卖出等量up应该获得的usdt数量，那么卖出数量对标池子数量，永远不去超卖
        uint256 bal = IERC20(usdtJia).balanceOf(address(UP));
        if (bal <= usdtnum) usdtnum = bal;

        //取10%假u，继续回流到UP-USDT池
        uint256 _rw = (usdtnum * huiliuams / 100);
        usdtnum = usdtnum - _rw;
        IERC20(usdtJia).transfer(UP, _rw);

        //取10假u，取10%购买并销毁AMS
        uint256 _xhu = (usdtnum * buyamsr / 100);
        usdtnum = usdtnum - _xhu;
        //假u购买ams，销毁
        INewAms(amsswap).upSellUsdtAndAms(_xhu, 0, address(0));

        //余下假u兑换真u给用户
        INewAms(amsswap).upSellUsdtAndAms(usdtnum, 1, msg.sender);
    }


}