/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-08
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
    
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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

            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; 

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }

    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }
}

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

        
}


interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Burn(address indexed owner, address indexed to, uint256 value);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }


    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }


    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }


    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }


    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }


    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

interface Share {
    function share(uint256 amount) external returns (uint256 eachLPIncome);
}

contract BWB is IBEP20, Auth {
    using SafeMath for uint256;


    string constant _name = "BWB";
    string constant _symbol = "BWB";
    uint8 constant _decimals = 18;

    uint256 _totalSupply = 21000000 * (10**_decimals);

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    IUniswapV2Router02 public uniswapV2Router;
    IERC20 public uniswapV2Pair;

    address public pair;
    address public dexRouter;

    address public USDT;


    address DEAD = 0x000000000000000000000000000000000000dEaD;

    address marketAddess;

    address NFTAddress; 

    address superNodeAddress;


    address _initAddress;

    mapping(address => bool) _inFeeFreeAccount;
    mapping(address => bool) _outFeeFreeAccount;


    uint256 feeDenominator = 10000;

    uint256 buyBurnFee = 100;
    uint256 buySuperNodeFee = 300;
    uint256 buyMarketFee = 100;
    uint256 buyNFTFee = 100;

    

    uint256 sellBurnFee = 200;
    uint256 sellSuperNodeFee = 500;
    uint256 sellMarketFee = 100;
    uint256 sellNFTFee = 200; 

    uint256 public maxBurnTotal = 18900000 * (10 **_decimals);


    constructor(address _dexRouter, address _USDT) Auth(msg.sender) {
        dexRouter = _dexRouter;
        USDT = _USDT;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(dexRouter);
        uniswapV2Router = _uniswapV2Router;
        pair = IPancakeFactory(_uniswapV2Router.factory()).createPair(
            address(this),
            USDT
        );


        mint(_totalSupply);

        _initAddress = msg.sender;
        
    }

    function mint(uint256 total) internal returns (bool) {

        _balances[owner] = total;
        return true;
    }


    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure override returns (uint8) {
        return _decimals;
    }

    function symbol() external pure override returns (string memory) {
        return _symbol;
    }

    function name() external pure override returns (string memory) {
        return _name;
    }

    function getOwner() external view override returns (address) {
        return owner;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    receive() external payable {}

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, _totalSupply);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(_balances[msg.sender] >= amount, "Transfer amount exceeds allowance");
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(_allowances[sender][msg.sender] >= amount, "Transfer amount exceeds allowance");
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return _transferFrom(sender, recipient, amount);
    }


    function _transferFrom(address sender, address recipient, uint256 amount) internal returns(bool) {

        if( recipient == pair && IERC20(recipient).totalSupply() == 0  ){
            require(sender == _initAddress,"not allow init");
            return _basicTransfer(sender, recipient, amount);
        }

        uint256 finalAmount = amount;

        if (recipient == pair) {

            if (_outFeeFreeAccount[sender] != true) {
                uint256 burnAmount = amount.mul(sellBurnFee).div(feeDenominator);

                if (maxBurnTotal > 0) {
                    if (burnAmount > maxBurnTotal) {
                        burnAmount = maxBurnTotal;
                    } 

                    burn(sender, burnAmount);
                } else {
                    burnAmount = 0;
                }
                
                NTFAccumulate(sender, amount.mul(sellNFTFee).div(feeDenominator));
                market(sender, amount.mul(sellMarketFee).div(feeDenominator));
                superNode(sender, amount.mul(sellSuperNodeFee).div(feeDenominator));
                finalAmount = amount.mul(feeDenominator.sub(sellSuperNodeFee).sub(sellNFTFee).sub(sellMarketFee)).div(feeDenominator).sub(burnAmount);
            }
             
        }

        if (sender == pair) { 
            if (_inFeeFreeAccount[recipient] == false) {
                uint256 burnAmount = amount.mul(buyBurnFee).div(feeDenominator);
                if (maxBurnTotal > 0) {
                    if (burnAmount > maxBurnTotal) {
                        burnAmount = maxBurnTotal;
                    } 

                    burn(sender, burnAmount);
                } else {
                    burnAmount = 0;
                }

                NTFAccumulate(sender, amount.mul(buyNFTFee).div(feeDenominator));
                market(sender, amount.mul(buyMarketFee).div(feeDenominator));
                superNode(sender, amount.mul(buySuperNodeFee).div(feeDenominator));

                finalAmount = amount.mul(feeDenominator.sub(buySuperNodeFee).sub(buyNFTFee).sub(buyMarketFee)).div(feeDenominator).sub(burnAmount);
            }
        }
        

        _basicTransfer(sender, recipient, finalAmount);
        return true;
    }


    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(_balances[sender] >= amount, "Insufficient Tokens");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
        return true;
    }
    

    function burn(address sender, uint256 amount) internal returns(bool) {
        maxBurnTotal = maxBurnTotal.sub(amount);
        return _basicTransfer(sender, DEAD, amount);
    }

    function market(address sender, uint256 amount) internal returns(bool) {
        return _basicTransfer(sender, marketAddess, amount);
    }


    function NTFAccumulate(address sender, uint256 amount) internal returns(bool) {
        Share(NFTAddress).share(amount);
        return _basicTransfer(sender, NFTAddress, amount);
    }

    function superNode(address sender, uint256 amount) internal returns(bool) {
        return _basicTransfer(sender, superNodeAddress, amount);
    }


    function addInNoFeeAddress(address addr) public onlyOwner returns(bool) {
        _inFeeFreeAccount[addr] = true;
        return true;
    } 


    function addOutNoFeeAddress(address addr) public onlyOwner returns(bool) {
        _outFeeFreeAccount[addr] = true;
        return true;
    } 


    function addNoFeeAddress(address addr) public onlyOwner returns(bool) {
        addInNoFeeAddress(addr);
        addOutNoFeeAddress(addr);
        return true;
    }


    function delInNoFeeAddress(address addr) public onlyOwner returns(bool) {
        _inFeeFreeAccount[addr] = false;
        return true;
    } 


    function delOutNoFeeAddress(address addr) public onlyOwner returns(bool) {
        _outFeeFreeAccount[addr] = false;
        return true;
    } 


    function delNoFeeAddress (address addr) public onlyOwner returns(bool) {
        delInNoFeeAddress(addr);
        delOutNoFeeAddress(addr);
        return true;
    }


    function setMarket(address addr) public onlyOwner returns(bool) {
        
        delNoFeeAddress(marketAddess);
        marketAddess = addr;
        addNoFeeAddress(marketAddess);
        return true;
    }

    function setNFT(address addr) public onlyOwner returns(bool) {
        
        delNoFeeAddress(NFTAddress);
        NFTAddress = addr;
        addNoFeeAddress(NFTAddress);
        return true;
    }

    function setNodeAddress(address addr) public onlyOwner returns(bool) {
        delNoFeeAddress(superNodeAddress);
        superNodeAddress = addr;
        addNoFeeAddress(superNodeAddress);
        return true;
    }

    function setBuyFee(
        uint256 _buyBurnFee,
        uint256 _buyMarketFee,
        uint256 _buySuperNodeFee,
        uint256 _buyNFTFee
    ) public onlyOwner returns(uint256, uint256, uint256, uint256) {
        require(_buyBurnFee >= 0, "Data error");
        require(_buyMarketFee >= 0, "Data error");
        require(_buySuperNodeFee >= 0, "Data error");
        require(_buyNFTFee >= 0, "Data error");

        require(_buyBurnFee.add(_buyMarketFee).add(_buySuperNodeFee).add(_buyNFTFee) <= feeDenominator, "Rate over limit");

        buyBurnFee = _buyBurnFee;
        buyMarketFee = _buyMarketFee;
        buySuperNodeFee = _buySuperNodeFee;
        buyNFTFee = _buyNFTFee;

        return (buyBurnFee, buyMarketFee, buySuperNodeFee, buyNFTFee);

    }

    function setSellFee(
        uint256 _sellBurnFee,
        uint256 _sellMarketFee,
        uint256 _sellSuperNodeFee,
        uint256 _sellNFTFee
    ) public onlyOwner returns(uint256, uint256, uint256, uint256) {
        require(_sellBurnFee >= 0, "Data error");
        require(_sellMarketFee >= 0, "Data error");
        require(_sellSuperNodeFee >= 0, "Data error");
        require(_sellNFTFee >= 0, "Data error");

        require(_sellBurnFee.add(_sellMarketFee).add(_sellSuperNodeFee).add(_sellNFTFee) <= feeDenominator, "Rate over limit");

        sellBurnFee = _sellBurnFee;
        sellMarketFee = _sellMarketFee;
        sellSuperNodeFee = _sellSuperNodeFee;
        sellNFTFee = _sellNFTFee;

        return (sellBurnFee, sellMarketFee, sellSuperNodeFee, sellNFTFee);

    }

}