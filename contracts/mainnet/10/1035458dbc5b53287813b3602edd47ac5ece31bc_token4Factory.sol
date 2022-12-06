/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.6;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);
}


library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex;
            }
            set._values.pop();
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e003");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e004");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e005");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e006");
        uint256 c = a / b;
        return c;
    }
}

interface swapRouter {

    function factory() external pure returns (address);

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

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);


    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

contract middleContract is Ownable {
    address public caller;
    constructor (address _account)  {
        caller = _account;

    }
    function claimToken(IERC20 _token) external {
        require(msg.sender == caller);
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }
}


interface ICoSoPair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract Token4 is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public buyerSet; //whitelist for buyer
    mapping(address => bool) public sellerSet; //whitelist for seller
    mapping(address => bool) public transferSet; //whitelist for transfer
    mapping(address => bool) public contractList; //whitelist for contract address

    address public marketAddress;
    //    address public devAddress;
    address public deadAddress = address(0);

    address[] public feeListForBuy;
    address[] public feeListForSell;
    address[] public feeListForTransfer;

    address public WETH;
    address public swapAndLiquifyToken;
    swapRouter public routerAddress;
    EnumerableSet.AddressSet private pairAddressList;
    uint256 private _totalSupply;
    middleContract public middleContractAddress;

    uint256 public buyFeeForMarket = 0;
    uint256 public buyFeeForBurn = 0;
    uint256 public buyFeeForAddPool = 0;
    uint256 public buyFeeForTeam = 0;

    uint256 public sellFeeForMarket = 0;
    uint256 public sellFeeForBurn = 0;
    uint256 public sellFeeForAddPool = 0;
    uint256 public sellFeeForTeam = 0;

    uint256 public txFeeForMarket = 0;
    uint256 public txFeeForBurn = 0;
    uint256 public txFeeForAddPool = 0;
    uint256 public txFeeForTeam = 0;

    uint256 public minAddPoolAmount = 20 * (10 ** 18);
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    //for minter
    uint256 public maxSupply;
    mapping(address => bool)  public MinerList;

    struct buyFeeStruct {
        uint256 buyFeeForMarket;
        uint256 buyFeeForBurn;
        uint256 buyFeeForAddPool;
        uint256 buyFeeForTeam;
    }

    struct sellFeeStruct {
        uint256 sellFeeForMarket;
        uint256 sellFeeForBurn;
        uint256 sellFeeForAddPool;
        uint256 sellFeeForTeam;
    }

    struct txFeeStruct {
        uint256 txFeeForMarket;
        uint256 txFeeForBurn;
        uint256 txFeeForAddPool;
        uint256 txFeeForTeam;
    }

    struct feeAddressListStruct {
        address[] feeListForBuy;
        address[] feeListForSell;
        address[] feeListForTransfer;
    }

    struct swapInfoStruct {
        bool canAddLiquify;
        address marketAddress;
        address routerAddress;
        address swapAndLiquifyToken;
        address WETH;
        uint256 minAddPoolAmount;
    }

    struct tokenStruct {
        uint256 decimals;
        buyFeeStruct buyFee;
        sellFeeStruct sellFee;
        txFeeStruct txFee;
        feeAddressListStruct feeAddressList;
        swapInfoStruct swapInfo;
    }

    struct feeStruct {
        uint256 marketFee;
        uint256 burnFee;
        uint256 liquidityFee;
        uint256 teamFee;
        uint256 txAmount;
        uint256 feeListNum;
        uint256 teamPerFee;
    }

    bool public canAddLiquify = false;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event swapAndLiquifyEvent(uint256 amount);
    event addPairEvent(address _pair, uint256 _time);
    event transferType(string _type, address sender, address recipient, uint256 amount);

    constructor (address newOwner_, string memory name_, string memory symbol_, uint256 decimals_, uint256 totalSupply_, uint256 _preSupply)  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        //for minter
        maxSupply = totalSupply_.mul(10 ** decimals_);
        uint256 preSupply = _preSupply.mul(10 ** decimals_);
        _totalSupply = preSupply;
        _balances[newOwner_] = preSupply;
        MinerList[newOwner_] = true;
        emit Transfer(address(0), newOwner_, preSupply);

        middleContractAddress = new middleContract(address(this));
        buyerSet[newOwner_] = true;
        sellerSet[newOwner_] = true;
        transferSet[newOwner_] = true;
        buyerSet[address(this)] = true;
        sellerSet[address(this)] = true;
        transferSet[address(this)] = true;
        transferSet[deadAddress] = true;
        transferSet[address(middleContractAddress)] = true;
        contractList[address(this)] = true;
        contractList[address(middleContractAddress)] = true;
    }

    function setSwapInfo(bool _canAddLiquify, swapRouter _routerAddress, address _WETH, address _swapAndLiquifyToken, uint256 _amount, uint256 _minAddPoolAmount) external onlyOwner {
        require(address(_routerAddress) != address(0));
        require(_WETH != address(0));
        require(_swapAndLiquifyToken != address(0));
        canAddLiquify = _canAddLiquify;
        routerAddress = _routerAddress;
        WETH = _WETH;
        swapAndLiquifyToken = _swapAndLiquifyToken;
        minAddPoolAmount = _minAddPoolAmount;
        IERC20(address(this)).approve(address(_routerAddress), _amount);
        if (_swapAndLiquifyToken != WETH) {
            IERC20(_swapAndLiquifyToken).approve(address(_routerAddress), _amount);
        }
    }

    function setAddLiquifyMode(bool _canAddLiquify) external onlyOwner {
        canAddLiquify = _canAddLiquify;
    }

    function setBuyerSet(address[] calldata _buyerList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _buyerList.length; i++) {
            buyerSet[_buyerList[i]] = _status;
        }
    }

    function setSellerSet(address[] calldata _sellerList, bool _status) external onlyOwner {
        for (uint256 j = 0; j < _sellerList.length; j++) {
            sellerSet[_sellerList[j]] = _status;
        }
    }

    function setTransferSet(address[] calldata _transferList, bool _status) external onlyOwner {
        for (uint256 j = 0; j < _transferList.length; j++) {
            transferSet[_transferList[j]] = _status;
        }
    }

    function setContractList(address[] memory _contractAddressList, bool _status) external onlyOwner {
        for (uint256 j = 0; j < _contractAddressList.length; j++) {
            contractList[_contractAddressList[j]] = _status;
        }
    }

    function setWhiteList(address _user, bool _buySetStatus, bool _sellSetStatus, bool _transferSetStatus) external onlyOwner {
        buyerSet[_user] = _buySetStatus;
        sellerSet[_user] = _sellSetStatus;
        transferSet[_user] = _transferSetStatus;
    }

    function setBuyFees(uint256 _buyFeeForMarket, uint256 _buyFeeForBurn, uint256 _buyFeeForAddPool, uint256 _buyFeeForTeam) external onlyOwner {
        buyFeeForMarket = _buyFeeForMarket;
        buyFeeForBurn = _buyFeeForBurn;
        buyFeeForAddPool = _buyFeeForAddPool;
        buyFeeForTeam = _buyFeeForTeam;
    }

    function setSellFees(uint256 _sellFeeForMarket, uint256 _sellFeeForBurn, uint256 _sellFeeForAddPool, uint256 _sellFeeForTeam) external onlyOwner {
        sellFeeForMarket = _sellFeeForMarket;
        sellFeeForBurn = _sellFeeForBurn;
        sellFeeForAddPool = _sellFeeForAddPool;
        sellFeeForTeam = _sellFeeForTeam;
    }

    function setTxFees(uint256 _txFeeForMarket, uint256 _txFeeForBurn, uint256 _txFeeForAddPool, uint256 _txFeeForTeam) external onlyOwner {
        txFeeForMarket = _txFeeForMarket;
        txFeeForBurn = _txFeeForBurn;
        txFeeForAddPool = _txFeeForAddPool;
        txFeeForTeam = _txFeeForTeam;
    }

    function setFeeListForBuy(address[] memory _feeListForBuy) external onlyOwner {
        feeListForBuy = _feeListForBuy;
    }

    function setFeeListForSell(address[] memory _feeListForSell) external onlyOwner {
        feeListForSell = _feeListForSell;
    }

    function setFeeListForTransfer(address[] memory _feeListForTransfer) external onlyOwner {
        feeListForTransfer = _feeListForTransfer;
    }

    function setMinAddPoolAmount(uint256 _minAddPoolAmount) external onlyOwner {
        minAddPoolAmount = _minAddPoolAmount;
    }

    function setMarketAddress(address _marketAddress) external onlyOwner {
        marketAddress = _marketAddress;
    }

    function addPairAddressList(address[] calldata _pairAddressList) external onlyOwner {
        for (uint256 i = 0; i < _pairAddressList.length; i++) {
            pairAddressList.add(_pairAddressList[i]);
        }
    }

    function removePairAddressList(address[] calldata _pairAddressList) external onlyOwner {
        for (uint256 i = 0; i < _pairAddressList.length; i++) {
            if (pairAddressList.contains(_pairAddressList[i])) {
                pairAddressList.remove(_pairAddressList[i]);
            }
        }
    }

    function getPairAddressList() external view returns (address[] memory) {
        return pairAddressList.values();
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function getErc20TokenApproved(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.approve(address(routerAddress), _amount);
    }

    function getApproved(uint256 _amount) external onlyOwner {
        IERC20(address(this)).approve(address(routerAddress), _amount);
        if (swapAndLiquifyToken != address(0) && swapAndLiquifyToken != WETH) {
            IERC20(swapAndLiquifyToken).approve(address(routerAddress), _amount);
        }
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance2 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
        swapTokensForEth(half);
        uint256 newBalance2 = (swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this))).sub(initialBalance2);
        addLiquidity(otherHalf, newBalance2);
        emit swapAndLiquifyEvent(contractTokenBalance);
    }

    function swapAndLiquifyByOwner() external lockTheSwap onlyOwner {
        require(balanceOf(address(this)) >= minAddPoolAmount);
        uint256 contractTokenBalance = minAddPoolAmount;
        uint256 half = contractTokenBalance.div(2);
        uint256 otherHalf = contractTokenBalance.sub(half);
        uint256 initialBalance2 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
        swapTokensForEth(half);
        uint256 newBalance2 = (swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this))).sub(initialBalance2);
        addLiquidity(otherHalf, newBalance2);
        emit swapAndLiquifyEvent(contractTokenBalance);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        require(swapAndLiquifyToken != address(0), "swapAndLiquifyToken can not be zero address");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapAndLiquifyToken;

        if (swapAndLiquifyToken != WETH) {
            routerAddress.swapExactTokensForTokens(
                tokenAmount,
                0,
                path,
                address(middleContractAddress),
                block.timestamp
            );

            middleContractAddress.claimToken(IERC20(swapAndLiquifyToken));
        } else {
            routerAddress.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        require(swapAndLiquifyToken != address(0), "swapAndLiquifyToken can not be zero address");
        if (swapAndLiquifyToken != WETH) {
            routerAddress.addLiquidity(
                address(this),
                address(swapAndLiquifyToken),
                tokenAmount,
                ethAmount,
                0,
                0,
                owner(),
                block.timestamp
            );
        } else {
            routerAddress.addLiquidityETH{value : ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                owner(),
                block.timestamp
            );
        }
    }

    function getPairInfo(address _pair) public {
        uint256 i = 0;
        try ICoSoPair(_pair).token0() returns (address tokenA){
            if (tokenA == address(this)) {
                i = i.add(1);
            }
        } catch {}
        try ICoSoPair(_pair).token1() returns (address tokenB){
            if (tokenB == address(this)) {
                i = i.add(1);
            }
        } catch {}
        if (i == 1) {
            pairAddressList.add(_pair);
            emit addPairEvent(_pair, block.timestamp);
        }
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function takeSellFee(address sender, address recipient, uint256 amount, uint256 marketRate, uint256 burnRate, uint256 liquidityRate, uint256 teamRate, address[] memory teamList) private {
        feeStruct memory x = feeStruct(0, 0, 0, 0, 0, 0, 0);
        x.marketFee = marketRate > 0 ? amount.mul(marketRate).div(100) : 0;
        x.burnFee = burnRate > 0 ? amount.mul(burnRate).div(100) : 0;
        x.liquidityFee = liquidityRate > 0 ? amount.mul(liquidityRate).div(100) : 0;
        x.teamFee = teamRate > 0 ? amount.mul(teamRate).div(100) : 0;
        if (x.marketFee > 0) {
            _balances[marketAddress] = _balances[marketAddress].add(x.marketFee);
            emit Transfer(sender, marketAddress, x.marketFee);
        }
        if (x.burnFee > 0) {
            _balances[deadAddress] = _balances[deadAddress].add(x.burnFee);
            emit Transfer(sender, deadAddress, x.burnFee);
        }
        if (x.liquidityFee > 0) {
            _balances[address(this)] = _balances[address(this)].add(x.liquidityFee);
            emit Transfer(sender, address(this), x.liquidityFee);
        }
        if (x.teamFee > 0) {
            x.feeListNum = teamList.length;
            if (x.feeListNum > 0) {
                x.teamPerFee = x.teamFee.div(x.feeListNum);
                for (uint256 i = 0; i < x.feeListNum; i++) {
                    _balances[teamList[i]] = _balances[teamList[i]].add(x.teamPerFee);
                    emit Transfer(sender, teamList[i], x.teamPerFee);
                }
            } else {
                x.teamFee = 0;
            }
        }
        x.txAmount = amount.sub(x.marketFee).sub(x.burnFee).sub(x.liquidityFee).sub(x.teamFee);
        _balances[recipient] = _balances[recipient].add(x.txAmount);
        emit Transfer(sender, recipient, x.txAmount);
    }

    function addPair(address _address) private {
        //auto add pairAddress
        if (isContract(_address) && !pairAddressList.contains(_address) && !contractList[_address]) {
            getPairInfo(_address);
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "e007");
        require(recipient != address(0), "e008");
        _beforeTokenTransfer(sender, recipient, amount);
        addPair(sender);
        addPair(recipient);
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= minAddPoolAmount;
        if (
            canAddLiquify &&
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            !pairAddressList.contains(sender) && pairAddressList.contains(recipient) && !sellerSet[sender]
        ) {
            contractTokenBalance = minAddPoolAmount;
            swapAndLiquify(contractTokenBalance);
        }
        _balances[sender] = _balances[sender].sub(amount);
        if (pairAddressList.contains(recipient) && !sellerSet[sender]) {
            takeSellFee(sender, recipient, amount, sellFeeForMarket, sellFeeForBurn, sellFeeForAddPool, sellFeeForTeam, feeListForSell);
            emit transferType("Sell or addLiquify", sender, recipient, amount);
        } else if (pairAddressList.contains(sender) && !buyerSet[recipient]) {
            takeSellFee(sender, recipient, amount, buyFeeForMarket, buyFeeForBurn, buyFeeForAddPool, buyFeeForTeam, feeListForBuy);
            emit transferType("Buy or removeLiquify", sender, recipient, amount);
        } else {
            if (pairAddressList.contains(recipient)) {
                emit transferType("Sell or addLiquify", sender, recipient, amount);
            } else if (pairAddressList.contains(sender)) {
                emit transferType("Buy or removeLiquify", sender, recipient, amount);
            } else {
                emit transferType("Normal transfer", sender, recipient, amount);
            }
            if (!transferSet[sender] && !transferSet[recipient]) {
                takeSellFee(sender, recipient, amount, txFeeForMarket, txFeeForBurn, txFeeForAddPool, txFeeForTeam, feeListForTransfer);
            } else {
                takeSellFee(sender, recipient, amount, 0, 0, 0, 0, new address[](0));
            }
        }
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "e009");
        require(spender != address(0), "e010");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    //    function setDev(address _dev) external {
    //        require(msg.sender == owner() || msg.sender == devAddress, "not allowed");
    //        devAddress = _dev;
    //    }
    //for minter
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    //for minter
    function mint(address _to, uint256 _amount) public returns (bool) {
        require(MinerList[msg.sender], "only miner!");
        require(_totalSupply.add(_amount) <= maxSupply);
        _mint(_to, _amount);
        return true;
    }

    //for minter
    function addMiner(address _adddress) public onlyOwner {
        MinerList[_adddress] = true;
    }

    //for minter
    function removeMiner(address _adddress) public onlyOwner {
        MinerList[_adddress] = false;
    }

    function getToken() external view returns (tokenStruct memory tokenInfo) {
        tokenInfo.decimals = _decimals;
        tokenInfo.buyFee = buyFeeStruct(buyFeeForMarket, buyFeeForBurn, buyFeeForAddPool, buyFeeForTeam);
        tokenInfo.sellFee = sellFeeStruct(sellFeeForMarket, sellFeeForBurn, sellFeeForAddPool, sellFeeForTeam);
        tokenInfo.txFee = txFeeStruct(txFeeForMarket, txFeeForBurn, txFeeForAddPool, txFeeForTeam);
        tokenInfo.feeAddressList = feeAddressListStruct(feeListForBuy, feeListForSell, feeListForTransfer);
        tokenInfo.swapInfo = swapInfoStruct(canAddLiquify, marketAddress, address(routerAddress), swapAndLiquifyToken, WETH, minAddPoolAmount);
    }

    receive() external payable {}
}

interface tokenFactoryList {
    function addToken(address _factoryAddress, string memory _factoryName, address _token, address _owner, string memory name_, string memory symbol_, uint256 decimals_, uint256 totalSupply_, bool _has_miner_mode, uint256 preSupply_) external;
}

contract token4Factory is Ownable {
    tokenFactoryList public tokenFactoryListAddress;

    constructor(tokenFactoryList _tokenFactoryListAddress) {
        setTokenFactoryListAddress(_tokenFactoryListAddress);
    }

    function setTokenFactoryListAddress(tokenFactoryList _tokenFactoryListAddress) public onlyOwner {
        tokenFactoryListAddress = _tokenFactoryListAddress;
    }

    function createToken(
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        bool _has_miner_mode,
        uint256 preSupply_,
        address _marketAddress,
        uint256[] memory _buyFeeList,
        uint256[] memory _sellFeeList,
        uint256[] memory _txFeeList
    ) external {
        require(address(tokenFactoryListAddress) != address(0), "k001");
        require(msg.sender == address(tokenFactoryListAddress), "k002");
        require(_has_miner_mode, "k003");
        require(_buyFeeList.length == 4 && _sellFeeList.length == 4 && _txFeeList.length == 4, "k004");
        address token = address(new Token4(newOwner_, name_, symbol_, decimals_, totalSupply_, preSupply_));
        Token4(payable(token)).setMarketAddress(_marketAddress);
        Token4(payable(token)).setBuyFees(_buyFeeList[0], _buyFeeList[1], _buyFeeList[2], _buyFeeList[3]);
        Token4(payable(token)).setSellFees(_sellFeeList[0], _sellFeeList[1], _sellFeeList[2], _sellFeeList[3]);
        Token4(payable(token)).setTxFees(_txFeeList[0], _txFeeList[1], _txFeeList[2], _txFeeList[3]);
        //change owner
        Token4(payable(token)).transferOwnership(newOwner_);
        tokenFactoryListAddress.addToken(address(this), "Token4", token, newOwner_, name_, symbol_, decimals_, totalSupply_, _has_miner_mode, preSupply_);
    }
}