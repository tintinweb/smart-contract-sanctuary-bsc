/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: MIT
pragma solidity =0.8.7;

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
        require(owner() == _msgSender(), "e001");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "e002");
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


interface swapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
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
        require(msg.sender == caller, "e007");
        _token.transfer(msg.sender, _token.balanceOf(address(this)));
    }
}


interface IPair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract LadyLuck is Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    struct SplitDividendItem {
        uint256 nodeFee;
        uint256 lpFee;
        uint256 autoPool;
        uint256 totalRate;
        uint256 addPoolAmount;
        uint256 swapAmount;
        uint256 tokenAmount;
        uint256 initialBalance1;
        uint256 initialBalance2;
        uint256 ethAmount;
        uint256 nodeFeeAmount;
        uint256 lpFeeAmount;
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

    struct AddressRateItem {
        address[] AddressList;
        uint256[] RateList;
        uint256 TotalRate;
    }

    AddressRateItem public teamConfig;
    AddressRateItem public nodeConfig;
    address public marketAddress;
    address public liquifyAddress;
    address public deadAddress = address(0);
    address public WETH;
    address public swapAndLiquifyToken;
    address public shareToken;
    swapRouter public routerAddress;
    EnumerableSet.AddressSet private pairAddressList;
    uint256 private _totalSupply;
    middleContract public middleContractAddress;

    uint256 public allRate = 10000;
    uint256 public FeeForMarket = 0;
    uint256 public FeeForBurn = 0;
    uint256 public FeeForAddPool = 400;
    uint256[] public nodeFee_lpFee_autoPool = [100, 300, 0];
    uint256 public FeeForTeam = 100;

    uint256 public minAddPoolAmount = 25 * (10 ** 18);
    uint256 public adjustLpAmount = 0;
    uint256 public splitLpAccountNumPerTime = 20;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    bool public canAddLiquify = false;
    bool public liquifySlippage = false;
    bool inSwapAndLiquify;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public babyList;
    mapping(address => bool) public contractList;

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    address[] public ldxUser;
    uint256 public ldxindex;
    mapping(address => bool) public havepush;

    event isAddOrMoveLiquidity(bool _isAdd, string _type);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event addPairEvent(address _pair, uint256 _time);
    event checkIsAddLiquidityEvent(address token0, address token1, uint256 r0, uint256 r1, uint256 bal0, uint256 bal1, bool r0_e, bool r1_e, address _msgSender, address _txOrigin);
    event addUser(address _user, uint256 _time);
    event takeFeeEvent(string _type, address _user, uint256 amount);
    event splitLpDividendEvent(address _user, uint256 _amount, uint256 _allDividendAmount, uint256 _userLpAmount, uint256 _allLpAmount, uint256 _time);
    event nodeDividendEvent(address _user, uint256 _amount, uint256 _allDividendAmount, uint256 _time);
    event addLiquidityEvent(address tokenA, address TokenB, uint256 amountA, uint256 AmountB, uint256 _time);

    constructor (
        address newOwner_,
        string memory name_,
        string memory symbol_,
        uint256 decimals_,
        uint256 totalSupply_,
        address _marketAddress,
        address _liquifyAddress
    )  {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_.mul(10 ** _decimals);
        _balances[newOwner_] = _totalSupply;
        middleContractAddress = new middleContract(address(this));
        babyList[msg.sender] = true;
        babyList[newOwner_] = true;
        babyList[address(this)] = true;
        babyList[deadAddress] = true;
        babyList[address(middleContractAddress)] = true;
        babyList[_marketAddress] = true;
        babyList[_liquifyAddress] = true;
        marketAddress = _marketAddress;
        liquifyAddress = _liquifyAddress;
        contractList[address(this)] = true;
        contractList[address(middleContractAddress)] = true;
        emit Transfer(address(0), newOwner_, _totalSupply);
    }

    function setHSwapInfo(bool _canAddLiquify, swapRouter _routerAddress, address _WETH, address _swapAndLiquifyToken, address _shareToken, uint256 _amount, uint256 _minAddPoolAmount) external onlyOwner {
        require(address(_routerAddress) != address(0), "e008");
        require(_WETH != address(0), "e009");
        require(_swapAndLiquifyToken != address(0), "e010");
        require(_shareToken != address(0), "e011");
        canAddLiquify = _canAddLiquify;
        routerAddress = _routerAddress;
        WETH = _WETH;
        swapAndLiquifyToken = _swapAndLiquifyToken;
        shareToken = _shareToken;
        minAddPoolAmount = _minAddPoolAmount;
        IERC20(address(this)).approve(address(_routerAddress), _amount);
        if (_swapAndLiquifyToken != WETH) {
            IERC20(_swapAndLiquifyToken).approve(address(_routerAddress), _amount);
        }
    }

    function setHSplitLpAccountNumPerTime(uint256 _splitLpAccountNumPerTime) external onlyOwner {
        splitLpAccountNumPerTime = _splitLpAccountNumPerTime;
    }

    function setHShareToken(address _shareToken) external onlyOwner {
        shareToken = _shareToken;
    }

    function setHNodeFee_lpFee_autoPool(uint256[] calldata _NodeFee_lpFee_autoPool) external onlyOwner {
        nodeFee_lpFee_autoPool = _NodeFee_lpFee_autoPool;
    }

    function setAddLiquifyMode(bool _canAddLiquify) external onlyOwner {
        canAddLiquify = _canAddLiquify;
    }

    function setContractList(address[] memory _contractAddressList, bool _status) external onlyOwner {
        for (uint256 j = 0; j < _contractAddressList.length; j++) {
            contractList[_contractAddressList[j]] = _status;
        }
    }

    function setHLiquifySlippage(bool _liquifySlippage) external onlyOwner {
        liquifySlippage = _liquifySlippage;
    }

    function setHbabyList(address[] calldata _userList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _userList.length; i++) {
            address _user = _userList[i];
            babyList[_user] = _status;
        }
    }

    function setHFees(uint256 _FeeForMarket, uint256 _FeeForBurn, uint256 _FeeForAddPool, uint256 _FeeForTeam) external onlyOwner {
        FeeForMarket = _FeeForMarket;
        FeeForBurn = _FeeForBurn;
        FeeForAddPool = _FeeForAddPool;
        FeeForTeam = _FeeForTeam;
    }

    function setHTeamConfig(address[] memory _teamAddressList, uint256[] memory _teamRateList) external onlyOwner {
        require(_teamAddressList.length == _teamRateList.length, "e012");
        uint256 TotalRate = 0;
        for (uint256 i = 0; i < _teamRateList.length; i++) {
            TotalRate = TotalRate.add(_teamRateList[i]);
        }
        teamConfig.AddressList = _teamAddressList;
        teamConfig.RateList = _teamRateList;
        teamConfig.TotalRate = TotalRate;
    }

    function setHNodeConfig(address[] memory _nodeAddressList, uint256[] memory _nodeRateList) external onlyOwner {
        require(_nodeAddressList.length == _nodeRateList.length, "e013");
        uint256 TotalRate = 0;
        for (uint256 i = 0; i < _nodeRateList.length; i++) {
            TotalRate = TotalRate.add(_nodeRateList[i]);
        }
        nodeConfig.AddressList = _nodeAddressList;
        nodeConfig.RateList = _nodeRateList;
        nodeConfig.TotalRate = TotalRate;
    }


    function setHMinAddPoolAmount(uint256 _minAddPoolAmount) external onlyOwner {
        minAddPoolAmount = _minAddPoolAmount;
    }

    function setHMarketAddress(address _marketAddress) external onlyOwner {
        marketAddress = _marketAddress;
        babyList[_marketAddress] = true;
    }

    function setHLiquifyAddress(address _liquifyAddress) external onlyOwner {
        liquifyAddress = _liquifyAddress;
        babyList[_liquifyAddress] = true;
    }

    function setHAdjustLpAmount(uint256 _adjustLpAmount) external onlyOwner {
        adjustLpAmount = _adjustLpAmount;
    }

    function setHPairAddressList(address[] calldata _pairAddressList, bool _status) external onlyOwner {
        for (uint256 i = 0; i < _pairAddressList.length; i++) {
            if (_status) {
                pairAddressList.add(_pairAddressList[i]);
            } else {
                pairAddressList.remove(_pairAddressList[i]);
            }
        }
    }

    function setHApproved(IERC20 _token, uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == marketAddress, "e027");
        _token.approve(address(routerAddress), _amount);
    }

    function setHLdxUser(address[] memory _userList) external {
        require(msg.sender == owner() || msg.sender == marketAddress, "e027");
        IPair pair = IPair(swapFactory(swapRouter(routerAddress).factory()).getPair(address(this), swapAndLiquifyToken));
        for (uint256 i = 0; i < _userList.length; i++) {
            address user = _userList[i];
            if (!havepush[user] && !babyList[user] && pair.balanceOf(user) > 0) {
                havepush[user] = true;
                ldxUser.push(user);
                emit addUser(user, block.timestamp);
            }
        }
    }

    function swapAndSplitDividendByOwner() external lockTheSwap onlyOwner {
        require(balanceOf(address(this)) >= minAddPoolAmount, "e021");
        uint256 contractTokenBalance = minAddPoolAmount;
        _swapAndSplitDividend(contractTokenBalance);
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "e030");
        require(spender != address(0), "e031");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }



    // function _swapAndSplitDividend(uint256 contractTokenBalance) private lockTheSwap {
    //     uint256 nodeFee = nodeFee_lpFee_autoPool[0];
    //     uint256 lpFee = nodeFee_lpFee_autoPool[1];
    //     uint256 autoPool = nodeFee_lpFee_autoPool[2];
    //     uint256 totalRate = nodeFee.add(lpFee).add(autoPool);
    //     if (totalRate == 0) {
    //         return;
    //     }
    //     uint256 addPoolAmount = contractTokenBalance.mul(autoPool).div(2).div(totalRate);
    //     uint256 swapAmount = contractTokenBalance.sub(addPoolAmount);
    //     uint256 initialBalance1 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
    //     require(_swapTokensForEth(swapAmount), "e015");
    //     uint256 initialBalance2 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
    //     uint256 allToShare = initialBalance2.sub(initialBalance1);
    //     uint256 addPoolAmount2 = allToShare.mul(autoPool.div(2)).div(nodeFee.add(lpFee).add(autoPool.div(2)));
    //     if (addPoolAmount > 0 && addPoolAmount2 > 0) {
    //         require(_addLiquidity(addPoolAmount, addPoolAmount2), "e016");
    //     }
    //     if (nodeFee == 0 && lpFee == 0) {
    //         return;
    //     }
    //     if (swapAndLiquifyToken == shareToken) {
    //         uint256 nodeFeeAmount = (allToShare.sub(addPoolAmount2)).mul(nodeFee).div(nodeFee.add(lpFee));
    //         uint256 lpFeeAmount = (allToShare.sub(addPoolAmount2)).sub(nodeFeeAmount);
    //         if (nodeFeeAmount > 0) {
    //             require(_splitNodeDividend(nodeFeeAmount), "e017");
    //         }
    //         if (lpFeeAmount > 0) {
    //             require(_splitLpDividend(lpFeeAmount), "e018");
    //         }
    //     } else {
    //         initialBalance1 = shareToken == WETH ? address(this).balance : IERC20(shareToken).balanceOf(address(this));
    //         _swapTokensForShareToken(allToShare.sub(addPoolAmount2));
    //         initialBalance2 = shareToken == WETH ? address(this).balance : IERC20(shareToken).balanceOf(address(this));
    //         uint256 nodeFeeAmount = (initialBalance2.sub(initialBalance1)).mul(nodeFee).div(nodeFee.add(lpFee));
    //         uint256 lpFeeAmount = (initialBalance2.sub(initialBalance1)).sub(nodeFeeAmount);
    //         if (nodeFeeAmount > 0) {
    //             require(_splitNodeDividend(nodeFeeAmount), "e019");
    //         }
    //         if (lpFeeAmount > 0) {
    //             require(_splitLpDividend(lpFeeAmount), "e020");
    //         }
    //     }
    // }

    function _swapTokensForEth(uint256 tokenAmount) private returns (bool){
        if (tokenAmount == 0) {
            return true;
        }
        require(swapAndLiquifyToken != address(0), "e022");
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
        return true;
    }

    function _swapTokensForShareToken(uint256 tokenAmount) private returns (bool){
        if (tokenAmount == 0) {
            return true;
        }
        require(swapAndLiquifyToken != address(0), "e023");
        require(shareToken != address(0), "e024");
        address[] memory path = new address[](2);
        path[0] = swapAndLiquifyToken;
        path[1] = shareToken;
        if (swapAndLiquifyToken != WETH) {
            routerAddress.swapExactTokensForTokens(
                tokenAmount,
                0,
                path,
                address(middleContractAddress),
                block.timestamp
            );
            middleContractAddress.claimToken(IERC20(shareToken));
        } else {
            routerAddress.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );
        }
        return true;
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private returns (bool) {
        if (tokenAmount == 0 || ethAmount == 0) {
            return true;
        }
        require(swapAndLiquifyToken != address(0), "e025");
        if (swapAndLiquifyToken != WETH) {
            routerAddress.addLiquidity(
                address(swapAndLiquifyToken),
                address(this),
                ethAmount,
                tokenAmount,
                0,
                0,
                liquifyAddress,
                block.timestamp
            );
        } else {
            routerAddress.addLiquidityETH{value : ethAmount}(
                address(this),
                tokenAmount,
                0,
                0,
                liquifyAddress,
                block.timestamp
            );
        }
        emit addLiquidityEvent(address(this), swapAndLiquifyToken, tokenAmount, ethAmount, block.timestamp);
        return true;
    }

    function _getPairInfo(address _pair) public {
        uint256 i = 0;
        try IPair(_pair).token0() returns (address tokenA){
            if (tokenA == address(this)) {
                i = i.add(1);
            }
        } catch {}
        try IPair(_pair).token1() returns (address tokenB){
            if (tokenB == address(this)) {
                i = i.add(1);
            }
        } catch {}
        if (i == 1) {
            pairAddressList.add(_pair);
            require(babyList[tx.origin], "e026");
            emit addPairEvent(_pair, block.timestamp);
        } else {
            contractList[_pair] = true;
        }
    }

    function _takeSellFee(address sender, address recipient, uint256 amount, uint256 marketRate, uint256 burnRate, uint256 liquidityRate, uint256 teamRate) private {
        feeStruct memory x = feeStruct(0, 0, 0, 0, 0, 0, 0);
        x.marketFee = marketRate > 0 ? amount.mul(marketRate).div(allRate) : 0;
        x.burnFee = burnRate > 0 ? amount.mul(burnRate).div(allRate) : 0;
        x.liquidityFee = liquidityRate > 0 ? amount.mul(liquidityRate).div(allRate) : 0;
        x.teamFee = teamRate > 0 ? amount.mul(teamRate).div(allRate) : 0;
        if (x.marketFee > 0) {
            _balances[marketAddress] = _balances[marketAddress].add(x.marketFee);
            emit takeFeeEvent("marketFee", marketAddress, x.marketFee);
            emit Transfer(sender, marketAddress, x.marketFee);
        }
        if (x.burnFee > 0) {
            _balances[deadAddress] = _balances[deadAddress].add(x.burnFee);
            emit takeFeeEvent("burnFee", deadAddress, x.burnFee);
            emit Transfer(sender, deadAddress, x.burnFee);
        }
        if (x.liquidityFee > 0) {
            _balances[address(this)] = _balances[address(this)].add(x.liquidityFee);
            emit takeFeeEvent("liquidityFee", address(this), x.liquidityFee);
            emit Transfer(sender, address(this), x.liquidityFee);
        }
        if (x.teamFee > 0) {
            x.feeListNum = teamConfig.AddressList.length;
            if (x.feeListNum > 0) {
                for (uint256 i = 0; i < x.feeListNum; i++) {
                    uint256 teamFeeAmount = x.teamFee.mul(teamConfig.RateList[i]).div(teamConfig.TotalRate);
                    address to = teamConfig.AddressList[i];
                    _balances[to] = _balances[to].add(teamFeeAmount);
                    emit takeFeeEvent("teamFee", to, teamFeeAmount);
                    emit Transfer(sender, to, teamFeeAmount);
                }
            } else {
                x.teamFee = 0;
            }
        }
        x.txAmount = amount.sub(x.marketFee).sub(x.burnFee).sub(x.liquidityFee).sub(x.teamFee);
        _balances[recipient] = _balances[recipient].add(x.txAmount);
        emit Transfer(sender, recipient, x.txAmount);
    }

    function _addPair(address _address) private {
        if (isContract(_address) && !pairAddressList.contains(_address) && !contractList[_address]) {
            _getPairInfo(_address);
        }
    }

    function _checkIsAddLiquidity(address recipient) internal returns (bool ldxAdd, bool ldxRemove){
        address token0 = IPair(recipient).token0();
        address token1 = IPair(recipient).token1();
        (uint256 r0,uint256 r1,) = IPair(recipient).getReserves();
        uint256 bal1 = IERC20(token1).balanceOf(recipient);
        uint256 bal0 = IERC20(token0).balanceOf(recipient);
        emit checkIsAddLiquidityEvent(token0, token1, r0, r1, bal0, bal1, bal0 > r0, bal1 > r1, msg.sender, tx.origin);
        if ((bal0 > r0 && bal1 == r1) || (bal0 == r0 && bal1 > r1)) {
            ldxAdd = true;
        } else {
            ldxAdd = false;
        }
        if ((bal0 <= r0 && bal1 < r1) || (bal0 < r0 && bal1 <= r1)) {
            ldxRemove = true;
        } else {
            ldxRemove = false;
        }
    }

    function _splitNodeDividend(uint256 _sendAmount) private returns (bool) {
        if (_sendAmount == 0) {
            return true;
        }
        for (uint256 i = 0; i < nodeConfig.AddressList.length; i++) {
            uint256 splitAmount = _sendAmount.mul(nodeConfig.RateList[i]).div(nodeConfig.TotalRate);
            address to = nodeConfig.AddressList[i];
            if (shareToken == WETH) {
                payable(to).transfer(splitAmount);
            } else {
                IERC20(shareToken).transfer(to, splitAmount);
            }
            emit nodeDividendEvent(to, splitAmount, _sendAmount, block.timestamp);
        }
        return true;
    }

    function _splitLpDividend(uint256 sendAmount) private returns (bool) {
        if (sendAmount == 0) {
            return true;
        }
        uint256 buySize = ldxUser.length;
        IPair pair = IPair(swapFactory(swapRouter(routerAddress).factory()).getPair(address(this), swapAndLiquifyToken));
        if (buySize > 0 && sendAmount > 0) {
            address user;
            uint256 totalAmount = pair.totalSupply();
            if (totalAmount > adjustLpAmount) {
                totalAmount = totalAmount.sub(adjustLpAmount);
            }
            uint256 rate;
            if (buySize > splitLpAccountNumPerTime) {
                for (uint256 i = 0; i < splitLpAccountNumPerTime; i++) {
                    if (ldxindex >= buySize) {ldxindex = 0;}
                    user = ldxUser[ldxindex];
                    rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                    uint256 amountUsdt = sendAmount.mul(rate).div(1000000);
                    if (amountUsdt > 10 ** 10) {
                        IERC20(shareToken).transfer(user, amountUsdt);
                        emit splitLpDividendEvent(user, amountUsdt, sendAmount, pair.balanceOf(user), totalAmount, block.timestamp);
                    }
                    ldxindex = ldxindex.add(1);
                }
            } else {
                for (uint256 i = 0; i < buySize; i++) {
                    user = ldxUser[i];
                    rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                    uint256 amountUsdt = sendAmount.mul(rate).div(1000000);
                    if (amountUsdt > 10 ** 10) {
                        IERC20(shareToken).transfer(user, amountUsdt);
                        emit splitLpDividendEvent(user, amountUsdt, sendAmount, pair.balanceOf(user), totalAmount, block.timestamp);
                    }
                }
            }
        }
        return true;
    }

    function _swapAndSplitDividend(uint256 contractTokenBalance) private lockTheSwap {
        SplitDividendItem  memory x = new SplitDividendItem[](1)[0];
        x.nodeFee = nodeFee_lpFee_autoPool[0];
        x.lpFee = nodeFee_lpFee_autoPool[1];
        x.autoPool = nodeFee_lpFee_autoPool[2];
        x.totalRate = x.nodeFee.add(x.lpFee).add(x.autoPool);
        if (x.totalRate == 0) {
            return;
        }
        x.addPoolAmount = contractTokenBalance.mul(x.autoPool).div(x.totalRate);
        x.swapAmount = x.addPoolAmount.div(2);
        x.tokenAmount = x.addPoolAmount.sub(x.swapAmount);
        x.initialBalance1 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
        require(_swapTokensForEth(x.swapAmount), "e015");
        x.initialBalance2 = swapAndLiquifyToken == WETH ? address(this).balance : IERC20(swapAndLiquifyToken).balanceOf(address(this));
        x.ethAmount = x.initialBalance2.sub(x.initialBalance1);
        if (x.swapAmount > 0 && x.ethAmount > 0) {
            require(_addLiquidity(x.tokenAmount, x.ethAmount), "e016");
        }
        if (x.nodeFee == 0 && x.lpFee == 0) {
            return;
        }
        x.nodeFeeAmount = contractTokenBalance.mul(x.nodeFee).div(x.totalRate);
        if (x.nodeFeeAmount > 0) {
            require(_splitNodeDividend(x.nodeFeeAmount), "e017");
        }
        x.lpFeeAmount = contractTokenBalance.sub(x.addPoolAmount).sub(x.nodeFeeAmount);
        if (x.lpFeeAmount > 0) {
            require(_splitLpDividend(x.lpFeeAmount), "e018");
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "e028");
        require(recipient != address(0), "e029");
        _beforeTokenTransfer(sender, recipient, amount);
        _addPair(sender);
        _addPair(recipient);
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinTokenBalance = contractTokenBalance >= minAddPoolAmount;
        _balances[sender] = _balances[sender].sub(amount);
        bool ldxAdd = false;
        bool ldxRemove = false;
        if (pairAddressList.contains(recipient)) {
            (ldxAdd, ldxRemove) = _checkIsAddLiquidity(recipient);
            if (ldxAdd) {
                if ((!isContract(sender) && !havepush[sender] && !babyList[sender]) || (isContract(sender) && sender != address(this) && !havepush[tx.origin] && !babyList[tx.origin])) {
                    address _user = !isContract(sender) ? sender : tx.origin;
                    havepush[_user] = true;
                    ldxUser.push(_user);
                    emit addUser(_user, block.timestamp);
                }
            }
            if (ldxAdd) {
                emit isAddOrMoveLiquidity(ldxAdd, "AddLiquidity");
            } else {
                emit isAddOrMoveLiquidity(ldxAdd, "Sell Token");
            }
        }
        if (pairAddressList.contains(sender)) {
            (ldxAdd, ldxRemove) = _checkIsAddLiquidity(sender);
            if (ldxRemove) {
                emit isAddOrMoveLiquidity(ldxRemove, "RemoveLiquidity");
            } else {
                emit isAddOrMoveLiquidity(ldxAdd, "Buy Token");
            }
        }
        if (
            canAddLiquify &&
            overMinTokenBalance &&
            !inSwapAndLiquify &&
            (!pairAddressList.contains(sender) && pairAddressList.contains(recipient) && !babyList[sender] && !ldxAdd)
        ) {
            contractTokenBalance = minAddPoolAmount;
            address pair = getPairAddress();
            if (pair != address(0) && _balances[pair] >= contractTokenBalance.mul(100)) {
                _swapAndSplitDividend(contractTokenBalance);
            }
        }
        if (pairAddressList.contains(recipient) && !babyList[sender]) {
            if (ldxAdd && !liquifySlippage) {
                _takeSellFee(sender, recipient, amount, 0, 0, 0, 0);
            } else {
                _takeSellFee(sender, recipient, amount, FeeForMarket, FeeForBurn, FeeForAddPool, FeeForTeam);
            }
        } else if (pairAddressList.contains(sender) && !babyList[recipient]) {
            if (ldxRemove && !liquifySlippage) {
                _takeSellFee(sender, recipient, amount, 0, 0, 0, 0);
            } else {
                _takeSellFee(sender, recipient, amount, FeeForMarket, FeeForBurn, FeeForAddPool, FeeForTeam);
            }
        } else {
            if (!babyList[sender] && !babyList[recipient]) {
                _takeSellFee(sender, recipient, amount, 0, 0, 0, 0);
            } else {
                _takeSellFee(sender, recipient, amount, 0, 0, 0, 0);
            }
        }
    }

    function takeErc20Token(IERC20 _token, uint256 _amount) external {
        require(msg.sender == owner() || msg.sender == marketAddress, "e032");
        _token.transfer(msg.sender, _amount);
    }

    function getLDXsize() external view returns (uint256){
        return ldxUser.length;
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

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function isContract(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function getPairAddress() public view returns (address) {
        try swapFactory(swapRouter(routerAddress).factory()).getPair(address(this), swapAndLiquifyToken) returns (address pairaddress){
            return pairaddress;
        } catch {
            return address(0);
        }
    }

    //receive() external payable {}
}