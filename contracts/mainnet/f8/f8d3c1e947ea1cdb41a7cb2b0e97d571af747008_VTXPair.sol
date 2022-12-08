/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: GPL-3.0
// File: contracts\interfaces\IVTXPair.sol

pragma solidity >=0.8.17;

interface IVTXPair {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 reserveRatio,
            uint32 blockTimestampLast
        );

    function modus() external view returns (uint8);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(uint8, uint32, address, address) external;

    function getTxSupplyLength(address holder) external view returns (uint256 txSupplyLength);

    function getPrevTxBalanceAndSupply(address holder, uint16 step) external view returns (uint256 txBalanceValue, uint256 txSupplyValue);
}

// File: contracts\interfaces\IVTXERC20LP.sol

pragma solidity >=0.8.17;

interface IVTXERC20LP {

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external view returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: contracts\VTXERC20LP.sol

contract VTXERC20LP is IVTXERC20LP {

    string private constant _name = "VTX LP";
    string private constant _symbol = "VTX-LP";
    uint8 private constant _decimals = 18;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    bytes32 private _DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private constant _PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) private _nonces;

    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        _DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
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
 
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function DOMAIN_SEPARATOR() public view virtual override returns (bytes32) {
        return _DOMAIN_SEPARATOR;
    }

    function PERMIT_TYPEHASH() public view virtual override returns (bytes32) {
        return _PERMIT_TYPEHASH;
    }

    function nonces(address account) public view virtual override returns (uint256) {
        return _nonces[account];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {
        require(deadline >= block.timestamp, "VTX: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                _DOMAIN_SEPARATOR,
                keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _nonces[owner]++, deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "VTX: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }

    function _mint(address to, uint256 value) internal {
        _totalSupply = _totalSupply + value;
        _balances[to] = _balances[to] + value;
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal {
        _balances[from] = _balances[from] - value;
        _totalSupply = _totalSupply - value;
        emit Transfer(from, address(0), value);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        _balances[from] = _balances[from] - value;
        _balances[to] = _balances[to] + value;
        emit Transfer(from, to, value);
    } //Update

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

// File: contracts\libraries\Math.sol

pragma solidity >=0.8.17;

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// File: contracts\libraries\UQ112x112.sol

pragma solidity >=0.8.17;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// File: contracts\interfaces\IERC20.sol

pragma solidity >=0.8.17;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: contracts\interfaces\IVTXFactory.sol

pragma solidity >=0.8.17;

interface IVTXFactory {
    event PairCreated(address indexed token0, address indexed token1, uint32 indexed reserveRatio, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getReserveToken(address input) external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB, uint32 reserveRatio, uint8 modus) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// File: contracts\interfaces\IVTXCallee.sol

pragma solidity >=0.8.17;

interface IVTXCallee {
    function VTXCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

// File: contracts\interfaces\IVTXERC20.sol

pragma solidity >=0.8.17;

interface IVTXERC20 {

    event PairAdded(address indexed account);
    event VTXMinted(address indexed to, uint indexed value);
    event VTXBurned(address indexed from, uint indexed value);

    function addPair (address account) external returns (bool);

    function VTXMint(address to, uint value) external returns (bool);
    
    function VTXBurn(address from, uint value) external returns (bool);

    function balanceBurn(address from, uint value) external returns (bool);
}

// File: contracts\utils\TxSupplyMapping.sol

pragma solidity >= 0.8.17;

contract TxSupplyMapping {

    struct TxData {
        uint256 txBalance;
        uint256 txSupplyValue;
    }
    
    mapping(address => TxData[]) internal txSupply;

    event Buy (address indexed holder, uint256 indexed TxTokenAmount, uint256 indexed TxPoolSupply);
    event Sell (address indexed holder, uint256 indexed TxTokenAmount);

    // Left shift each array element then remove the last element
    // Effectively the same as deleting the FIRST element in the storage array
    function leftShiftArray(address holder) internal {
        for (uint i; i < txSupply[holder].length -1 && txSupply[holder].length != 0; i++) {
            txSupply[holder][i] = txSupply[holder][i + 1];
            }
            txSupply[holder].pop();
    }

    function getTxSupplyLength(address holder) public virtual view returns (uint256 txSupplyLength) {
        return txSupply[holder].length;
    }

    function getTxBalanceAndSupply(address holder) public virtual view returns (TxData[] memory) {
        return txSupply[holder];
    }

    function getPrevTxBalanceAndSupply(address holder, uint16 step) public virtual view returns (uint256 txBalanceValue, uint256 txSupplyValue) {
        (txBalanceValue, txSupplyValue) = txSupply[holder].length > 0 && step <= txSupply[holder].length -1 
                                        ? (txSupply[holder][step].txBalance, txSupply[holder][step].txSupplyValue)
                                        : (0, 0);
    }

    function updateTxBalanceAndSupply(address holder, uint256 txTokenAmount, uint256 newTxSupplyValue) public returns (bool) {
        txSupply[holder].push(TxData(txTokenAmount, newTxSupplyValue));
        emit Buy(holder, txTokenAmount, newTxSupplyValue);
        return true;
    }

    function updateTxBalanceOnSale(address holder, uint256 txTokenAmount) public returns (bool) {
        uint256 loggedTxTokenAmount = txTokenAmount; // Store txTokenAmount value before adjustment in function as a local variable
        if (txSupply[holder].length == 0) {
            emit Sell (holder, loggedTxTokenAmount);
            return true;
        }
        while (txSupply[holder].length > 0 && txTokenAmount > txSupply[holder][0].txBalance) {
                txTokenAmount = txTokenAmount - txSupply[holder][0].txBalance;
                leftShiftArray(holder);
                // Implement contingency in extemely unlikely situation whereby the transaction has so many iterations that max gas limit is reached
                if (txSupply[holder].length == 0) {
                    emit Sell (holder, loggedTxTokenAmount);
                    return true;
                } // Checks array length again after pop() and if it is now 0, emit Sell event and end this instance of function execution
                continue; // Otherwise, begin the next iteration of the "while" loop immediately
        } if (txTokenAmount < txSupply[holder][0].txBalance) {
            txSupply[holder][0].txBalance = txSupply[holder][0].txBalance - txTokenAmount;
            emit Sell (holder, loggedTxTokenAmount);
            return true;
        } else if (txTokenAmount == txSupply[holder][0].txBalance) {
            leftShiftArray(holder);
            emit Sell (holder, loggedTxTokenAmount);
            return true;
        } else {
            return false;
        }
    }
}

// File: contracts\VTXPair.sol

pragma solidity >=0.8.17;

contract VTXPair is IVTXPair, VTXERC20LP, TxSupplyMapping {
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    mapping(address => uint256) private _nonces;

    address public factory;
    address public token0;
    address public token1;

    uint8 public modus;
    uint32 public reserveRatio;

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, 'VTX: LOCKED');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function name() public view virtual override (IVTXPair, VTXERC20LP) returns (string memory) {
        return VTXERC20LP.name();
    }

    function symbol() public view virtual override (IVTXPair, VTXERC20LP) returns (string memory) {
        return VTXERC20LP.symbol();
    }

    function decimals() public view virtual override (IVTXPair, VTXERC20LP) returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override (IVTXPair, VTXERC20LP) returns (uint256) {
        return VTXERC20LP.totalSupply();
    }
 
    function balanceOf(address account) public view virtual override (IVTXPair, VTXERC20LP) returns (uint256) {
        return VTXERC20LP.balanceOf(account);
    }

    function allowance(address owner, address spender) public view virtual override (IVTXPair, VTXERC20LP) returns (uint256) {
        return VTXERC20LP.allowance(owner, spender);
    }

    function DOMAIN_SEPARATOR() public view virtual override (IVTXPair, VTXERC20LP) returns (bytes32) {
        return VTXERC20LP.DOMAIN_SEPARATOR();
    }

    function PERMIT_TYPEHASH() public view virtual override (IVTXPair, VTXERC20LP) returns (bytes32) {
        return VTXERC20LP.PERMIT_TYPEHASH();
    }

    function nonces(address account) public view virtual override (IVTXPair, VTXERC20LP) returns (uint256) {
        return VTXERC20LP.nonces(account);
    }

    function approve(address spender, uint256 amount) public virtual override (IVTXPair, VTXERC20LP) returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override (IVTXPair, VTXERC20LP) returns (bool) {
        VTXERC20LP.transfer(to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override (IVTXPair, VTXERC20LP) returns (bool) {
        VTXERC20LP.transferFrom(from, to, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override (IVTXPair, VTXERC20LP) {
        require(deadline >= block.timestamp, "VTX: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                VTXERC20LP.DOMAIN_SEPARATOR(),
                keccak256(abi.encode(VTXERC20LP.PERMIT_TYPEHASH(), owner, spender, value, _nonces[owner]++, deadline)) // Check nonces implementation here
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "VTX: INVALID_SIGNATURE");
        _approve(owner, spender, value);
    }

    function getTxSupplyLength(address holder) public virtual override (IVTXPair, TxSupplyMapping) view returns (uint256 txSupplyLength) {
        return TxSupplyMapping.getTxSupplyLength(holder);
    }

    function getPrevTxBalanceAndSupply(address holder, uint16 step) 
    public virtual override (IVTXPair, TxSupplyMapping) view returns (uint256 txBalanceValue, uint256 txSupplyValue) {
        return TxSupplyMapping.getPrevTxBalanceAndSupply(holder, step);
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _reserveRatio, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _reserveRatio = reserveRatio;
        _blockTimestampLast = blockTimestampLast;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VTX: TRANSFER_FAILED');
    }

    function _safeMintFrom(
        address token,
        address to,
        uint256 value
    ) private {
        // bytes4(keccak256(bytes('mintFrom(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x1cc74859, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VTX: mintFrom failed');
    }

    function _safeBurnFrom(
        address token,
        address from,
        uint256 value
    ) private {
        // bytes4(keccak256(bytes('burnFrom(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x79cc6790, from, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'VTX: burnFrom failed');
    }

    constructor() {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(uint8 _modus, uint32 _reserveRatio, address _token0, address _token1) external {
        require(msg.sender == factory, 'VTX: FORBIDDEN'); // sufficient check
        modus = _modus;
        reserveRatio = _reserveRatio;
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, 'VTX: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 8/25 of the growth in sqrt(k)
    //function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
    //    address feeTo = IVTXFactory(factory).feeTo();
    //    feeOn = feeTo != address(0);
    //    uint _kLast = kLast; // gas savings
    //    if (feeOn) {
    //        if (_kLast != 0) {
    //            uint rootK = Math.sqrt(uint(_reserve0) * (_reserve1));
    //            uint rootKLast = Math.sqrt(_kLast);
    //            if (rootK > rootKLast) {
    //                uint numerator = totalSupply * (rootK - (rootKLast)) * (8);
    //                uint denominator = rootK * (17).add(rootKLast * (8));
    //                uint liquidity = numerator / denominator;
    //                if (liquidity > 0) _mint(feeTo, liquidity);
    //            }
    //        }
    //    } else if (_kLast != 0) {
    //        kLast = 0;
    //    }
    //}

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external lock returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1, , ) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0 - (_reserve0);
        uint amount1 = balance1 - (_reserve1);

        //bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * (amount1)) - (MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0 * (_totalSupply) / _reserve0, amount1 * (_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'VTX: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        //if (feeOn) kLast = uint(reserve0) * (reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1, , ) = getReserves(); // gas savings
        address _token0 = token0;                                   // gas savings
        address _token1 = token1;                                   // gas savings
        uint liquidity = balanceOf(address(this));
        //bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        amount0 = liquidity * (balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity * (balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'VTX: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        //if (feeOn) kLast = uint(reserve0) * (reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'VTX: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1, , ) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'VTX: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for amount0In, amount1In, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'VTX: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer reserve tokens -> SELL
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer pool tokens -> BUY
        if (data.length > 0) IVTXCallee(to).VTXCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        uint tempAmount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint tempAmount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(tempAmount0In > 0 || tempAmount1In > 0, 'VTX: INSUFFICIENT_INPUT_AMOUNT');
        if (tempAmount0In > 0 && amount1Out > 0) {
            _safeMintFrom(_token1, address(this), amount1Out); // mint pool tokens to pair after BUY (equal to amount transferred out)
            if (modus == 1) updateTxBalanceAndSupply(to, amount1Out, IERC20(_token1).totalSupply()); // update tx balance and pool token supply for holder in storage
            }
        if (tempAmount1In > 0 && amount0Out > 0) {
            _safeBurnFrom(_token1, address(this), tempAmount1In); // burn pool tokens from pair after SELL (equal to amount transferred in)
            if (modus == 1) updateTxBalanceOnSale(tx.origin, tempAmount1In); // update tx balance for holder in storage
            }
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }

        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0; // Checks again outside the scope after updating balances first
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0; // Checks again outside the scope after updating balances first

        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        //uint balance0Adjusted = (balance0 * (10000) - (amount0In * (25)));
        //uint balance1Adjusted = (balance1 * (10000) - (amount1In * (25)));
        //require(balance0Adjusted * (balance1Adjusted) >= uint(_reserve0) * (_reserve1) * (10000**2), 'VTX: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)) - (reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)) - (reserve1));
    }

    // force reserves to match balances
    function sync() external lock {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }
}