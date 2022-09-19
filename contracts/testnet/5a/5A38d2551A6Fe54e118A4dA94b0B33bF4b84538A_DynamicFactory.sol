/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

// File: DynamicSwap-v2-core/contracts/interfaces/IDynamicPair.sol



pragma solidity >=0.6.0;



interface IDynamicPair {

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



    function vars(uint id) external view returns (uint32);

    function baseLinePrice0() external view returns (uint);

    function lastMA() external view returns (uint);

    function isPrivate() external view returns (bool);



    function votingTime() external view returns (uint);

    function minimalLevel() external view returns (uint);



    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;



    function initialize(address, address, uint32[8] calldata, bool, uint, uint32[2] calldata) external;



    function addReward(uint amount) external;

    function getRewards(address user) external view returns (uint);

    function getAmountOut(uint amountIn, address tokenIn, address tokenOut) external view returns(uint);

    function getAmountIn(uint amountOut, address tokenIn, address tokenOut) external view returns(uint);

    function setTokenTax(address token, address buyTaxReceiver, uint256 buyTax, address sellTaxReceiver, uint256 sellTax) external;

}


// File: DynamicSwap-v2-core/contracts/libraries/Clones.sol



pragma solidity ^0.6.0;



/**

 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for

 * deploying minimal proxy contracts, also known as "clones".

 *

 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies

 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.

 *

 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`

 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the

 * deterministic method.

 *

 * _Available since v3.4._

 */

library Clones {

    /**

     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.

     *

     * This function uses the create opcode, which should never revert.

     */

    function clone(address implementation) internal returns (address instance) {

        assembly {

            let ptr := mload(0x40)

            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

            mstore(add(ptr, 0x14), shl(0x60, implementation))

            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            instance := create(0, ptr, 0x37)

        }

        require(instance != address(0), "ERC1167: create failed");

    }



    /**

     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.

     *

     * This function uses the create2 opcode and a `salt` to deterministically deploy

     * the clone. Using the same `implementation` and `salt` multiple time will revert, since

     * the clones cannot be deployed twice at the same address.

     */

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {

            let ptr := mload(0x40)

            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

            mstore(add(ptr, 0x14), shl(0x60, implementation))

            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

            instance := create2(0, ptr, 0x37, salt)

        }

        require(instance != address(0), "ERC1167: create2 failed");

    }



    /**

     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.

     */

    function predictDeterministicAddress(

        address implementation,

        bytes32 salt,

        address deployer

    ) internal pure returns (address predicted) {

        assembly {

            let ptr := mload(0x40)

            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

            mstore(add(ptr, 0x14), shl(0x60, implementation))

            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)

            mstore(add(ptr, 0x38), shl(0x60, deployer))

            mstore(add(ptr, 0x4c), salt)

            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))

            predicted := keccak256(add(ptr, 0x37), 0x55)

        }

    }



    /**

     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.

     */

    function predictDeterministicAddress(address implementation, bytes32 salt)

        internal

        view

        returns (address predicted)

    {

        return predictDeterministicAddress(implementation, salt, address(this));

    }

}


// File: DynamicSwap-v2-core/contracts/interfaces/IWETH.sol



pragma solidity >=0.6.0;



interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}


// File: DynamicSwap-v2-core/contracts/interfaces/IERC20.sol



pragma solidity >=0.6.0;



interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);



    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);



    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);



    function mint(address to, uint256 amount) external returns (bool);

}


// File: DynamicSwap-v2-core/contracts/interfaces/IDynamicFactory.sol



pragma solidity >=0.6.0;



interface IDynamicFactory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function dynamic() external view returns (address);

    function WETH() external view returns (address);

    function uniV2Router() external view returns (address);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair);

    function createPair(

        address tokenA, 

        address tokenB, 

        uint32[8] calldata _vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) external returns (address pair);

    

    //function setFeeTo(address) external;

    function setFeeToSetter(address) external;



    function mintReward(address to, uint amount) external;

    function swapFee(address token0, address token1, uint fee0, uint fee1) external returns(bool);

    function setVars(uint varId, uint32 value) external;

    function setRouter(address _router) external;

    function setReimbursementContractAndVault(address _reimbursement, address _vault) external;

    function claimFee() external returns (uint256);

    function getColletedFees() external view returns (uint256 feeAmount);

    function pairImplementation() external view returns (address);

}


// File: DynamicSwap-v2-core/contracts/interfaces/IDynamicRouter01.sol



pragma solidity >=0.6.2;



interface IDynamicRouter01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);



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

    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);



    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    //function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    //function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}


// File: DynamicSwap-v2-core/contracts/interfaces/IDynamicRouter02.sol



pragma solidity >=0.6.2;




interface IDynamicRouter02 is IDynamicRouter01 {

    // Create pair with options 

    function createPair(

        address tokenA,

        address tokenB,

        uint amountA,

        uint amountB,

        address to,

        uint32[8] memory vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor        

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) external returns (uint liquidity);



    function createPairETH(

        address token,

        uint amountToken,

        address to,

        uint32[8] memory vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor        

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) external payable returns (uint liquidity);



    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}


// File: DynamicSwap-v2-core/contracts/DynamicFactory.sol



pragma solidity =0.6.12;







//import './DynamicPair.sol';



interface IReimbursement {

    // returns fee percentage with 2 decimals

    function getLicenseeFee(address vault, address projectContract) external view returns(uint256);

    // returns fee receiver address or address(0) if need to refund fee to user.

    function requestReimbursement(address user, uint256 feeAmount, address vault) external returns(address);

}



contract DynamicFactory {

    enum Vars {timeFrame, maxDump0, maxDump1, maxTxDump0, maxTxDump1, coefficient, minimalFee, periodMA}

    uint32[8] public vars; // timeFrame, maxDump0, maxDump1, maxTxDump0, maxTxDump1, coefficient, minimalFee, periodMA

    //timeFrame = 1 days;  // during this time frame rate of reserve1/reserve0 should be in range [baseLinePrice0*(1-maxDump0), baseLinePrice0*(1+maxDump1)]

    //maxDump0 = 10000;   // maximum allowed dump (in percentage with 2 decimals) of reserve1/reserve0 rate during time frame relatively the baseline

    //maxDump1 = 10000;   // maximum allowed dump (in percentage with 2 decimals) of reserve0/reserve1 rate during time frame relatively the baseline

    //maxTxDump0 = 10000; // maximum allowed dump (in percentage with 2 decimals) of token0 price per transaction

    //maxTxDump1 = 10000; // maximum allowed dump (in percentage with 2 decimals) of token1 price per transaction

    //coefficient = 10000; // coefficient (in percentage with 2 decimals) to transform price growing into fee. ie

    //minimalFee = 5;   // Minimal fee percentage (with 2 decimals) applied to transaction. I.e. 5 = 0.05%

    //periodMA = 45 minutes;  // MA period in seconds

    address public dynamic;   // dynamic token address

    address public uniV2Router; // uniswap compatible router

    address public reimbursement; // address of users reimbursements contract

    address public reimbursementVault;  // address of company vault for reimbursements

    address public pairImplementation;  // pair implementation code contract (using in clone).

    address public feeTo;

    uint256 public feeToPart = 20; // company part of charged fee (in percentage). I.e. send to `feeTo` amount of (charged fee * feeToPart / 100)

    uint256 public feeReimbursement = 100;   // percent of fee to reimburse

    address public feeToSetter;

    //bool public defaultCircuitBreakerEnable = true; // protect from dumping token against WETH

    address public WETH;



    uint256 public nonce;

    mapping(address => mapping(address => address)) public getPair;

    address[] public allPairs;

    mapping(address => bool) isPair;



    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    constructor(address _feeToSetter, address _pairImplementation) public {

        require(_feeToSetter != address(0) && _pairImplementation != address(0), "Address zero");

        feeToSetter = _feeToSetter;

        pairImplementation = _pairImplementation;

        vars = [1 days, 10000, 10000, 10000, 10000, 10000, 5, 45 minutes];

    }



    function allPairsLength() external view returns (uint) {

        return allPairs.length;

    }



    function createPair(address tokenA, address tokenB) external returns (address pair) {

        require(getPair[tokenA][tokenB] == address(0), 'Dynamic: PAIR_EXISTS'); // single check is sufficient

        uint32[2] memory voteVars;

        voteVars[0] = 1 days;

        voteVars[1] = 100;

        return _createPair(tokenA, tokenB, vars, false, address(0), voteVars);

    }



    function createPair(

        address tokenA, 

        address tokenB, 

        uint32[8] calldata _vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) 

        external 

        returns (address pair) 

    {

        require(getPair[tokenA][tokenB] == address(0), 'Dynamic: PAIR_EXISTS'); // single check is sufficient

        return _createPair(tokenA, tokenB, _vars, isPrivate, protectedToken, voteVars);

    }



    function createPairFork(

        address tokenA, // for ETH use address WETH

        address tokenB, // for ETH use address WETH

        uint amountA,

        uint amountB,

        uint32[8] calldata _vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) 

        external 

        payable

        returns (address pair, uint liquidity)

    {

        pair = getPair[tokenA][tokenB];

        require(pair != address(0), 'Dynamic: FORK_ONLY_EXISTING'); // fork only existing pool



        //new pool should be bigger than old one;

        (uint reserve0, uint reserve1,) = IDynamicPair(pair).getReserves();

        if (tokenA < tokenB) require(reserve0 < amountA && reserve1 < amountB, "New pool smaller");

        else require(reserve0 < amountB && reserve1 < amountA, "New pool smaller");



        pair = _createPair(tokenA, tokenB, _vars, isPrivate, protectedToken, voteVars);



        if (msg.value != 0) {

            require(

                (tokenA == WETH && amountA == msg.value) || 

                (tokenB == WETH && amountB == msg.value), 

                "no WETH"

            );

            IWETH(WETH).deposit{value: msg.value}();

            require(IWETH(WETH).transfer(pair, msg.value));

            if (tokenA != WETH) _safeTransferFrom(tokenA, msg.sender, pair, amountA);

            else _safeTransferFrom(tokenB, msg.sender, pair, amountB);

        } else {

            _safeTransferFrom(tokenA, msg.sender, pair, amountA);

            _safeTransferFrom(tokenB, msg.sender, pair, amountB);

        }

        liquidity = IDynamicPair(pair).mint(msg.sender);

    } 



    // create pair without checking if it already exist

    function _createPair(

        address tokenA, 

        address tokenB, 

        uint32[8] memory _vars, 

        bool isPrivate, // is private pool

        address protectedToken, // which token should be protected by secure floor, if address(0) then without secure floor

        uint32[2] memory voteVars // [0] - voting delay, [1] - minimal level for proposal in percentage with 2 decimals i.e. 100 = 1%

    ) 

        internal 

        returns (address pair) 

    {

        require(tokenA != tokenB, 'Dynamic: IDENTICAL_ADDRESSES');

        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(token0 != address(0), 'Dynamic: ZERO_ADDRESS');

        uint baseProtectedToken = 2;

        if (protectedToken == token0) baseProtectedToken = 0;

        else if (protectedToken == token1) baseProtectedToken = 1;

        else require(protectedToken == address(0), "Wrong protected token");



        nonce++;

        bytes32 salt = keccak256(abi.encodePacked(token0, token1, nonce));

        pair = Clones.cloneDeterministic(pairImplementation, salt);

        IDynamicPair(pair).initialize(token0, token1, _vars, isPrivate, baseProtectedToken, voteVars);

        getPair[token0][token1] = pair;

        getPair[token1][token0] = pair; // populate mapping in the reverse direction

        allPairs.push(pair);

        isPair[pair] = true;

        emit PairCreated(token0, token1, pair, allPairs.length);

    }



    function setFeeTo(address _feeTo) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        feeTo = _feeTo;

    }



    function setFeeToSetter(address _feeToSetter) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        feeToSetter = _feeToSetter;

    }



    // mint dynamic tokens for LP

    function mintReward(address to, uint amount) external {

        require(isPair[msg.sender], "Only pair");

        //return; // TEST

        IERC20(dynamic).mint(to, amount);

    }



    function swapFee(address token0, address token1, uint fee0, uint fee1) external returns(bool) {

        //return false; // TEST

        uint gasA = gasleft();

        require(isPair[msg.sender], "Only pair");

        address _WETH = WETH;

        address _dynamic = dynamic;

        if ((token0 == _dynamic || token1 == _dynamic) && (token0 == _WETH || token1 == _WETH)) return false; // protection from loop when swap dynamic/WETH

        address _dynamicPair = getPair[_dynamic][_WETH];

        if (_dynamicPair == address(0)) return false;

        uint amount;

        uint fee;

        if (fee0 != 0) amount = _swapFee(_WETH, token0, fee0);

        if (fee1 != 0) amount += _swapFee(_WETH, token1, fee1);

        if (amount == 0) {

            if (reimbursement != address(0)) {

                fee = ((73000 + gasA - gasleft()) * tx.gasprice); // add gas for swap

                IReimbursement(reimbursement).requestReimbursement(tx.origin, fee, reimbursementVault);      // user reimbursement

            }

            return false;

        }

        (uint112 _reserve0, uint112 _reserve1,) = IDynamicPair(_dynamicPair).getReserves();

        if (_WETH > _dynamic) {

            (_reserve0, _reserve1) = (_reserve1, _reserve0);    // WETH amount = _reserve0

        }

        fee = amount;

        amount = (100 - feeToPart) * amount / 100; // amount in WETH to move to pool

        //_safeTransfer(WETH, _dynamicPair, amount);    // add fee to dynamic pool on one side

        //IDynamicPair(_dynamicPair).sync();    // sync in pair

        amount = (amount * _reserve1) / (_reserve0 + amount);

        IDynamicPair(msg.sender).addReward(amount); // amount in dynamic

        if (reimbursement != address(0)) {

            fee = (fee * feeReimbursement / 100) + ((73000 + gasA - gasleft()) * tx.gasprice); // add gas for swap

            IReimbursement(reimbursement).requestReimbursement(tx.origin, fee, reimbursementVault);      // user reimbursement

        }

        return true;

    }



    // swap token to WETH and return WETH amount

    function _swapFee(address _WETH, address _token, uint _feeAmount) internal returns(uint amountOut) {

        if (_token == _WETH) {

            _safeTransferFrom(_token, msg.sender, address(this), _feeAmount);

            return _feeAmount;

        }

        bool localPair;

        address _pair = getPair[_token][_WETH];

        if (_pair == address(0)) {

            address _factory = IDynamicRouter02(uniV2Router).factory();

            _pair = IDynamicFactory(_factory).getPair(_token, _WETH);

            if (_pair == address(0)) return 0;  // no pair token-WETH

        } else {

            // local factory

            localPair == true;

        }

        if (_pair == msg.sender) return 0;  // avoid deadlock on recursion

        _safeTransferFrom(_token, msg.sender, _pair, _feeAmount);

        (uint112 _reserve0, uint112 _reserve1,) = IDynamicPair(_pair).getReserves();

        if (_token > _WETH) _reserve0 = _reserve1;  // _reserve0 = reserve of _token

        // get amountInput for tokens with fee on transfer

        uint amountInput = IERC20(_token).balanceOf(address(_pair));

        if (amountInput > _reserve0) amountInput = amountInput - uint(_reserve0);

        else return 0;

        if (localPair) {

            amountOut = IDynamicPair(_pair).getAmountOut(amountInput, _token, _WETH);

        } else {

            address[] memory _path = new address[](2);

            _path[0] = _token;

            _path[1] = _WETH;

            uint256[] memory _amountOut = IDynamicRouter02(uniV2Router).getAmountsOut(amountInput, _path);

            amountOut = _amountOut[1];

        }

        if (amountOut == 0) return 0;



        if (_token < _WETH) {

            IDynamicPair(_pair).swap(0, amountOut, address(this), new bytes(0));

        } else {

            IDynamicPair(_pair).swap(amountOut, 0, address(this), new bytes(0));

        }

    }



    function _safeTransfer(address token, address to, uint value) internal {

        // bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');

    }



    function _safeTransferFrom(address token, address from, address to, uint value) internal {

        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');

    }



    function setVars(uint varId, uint32 value) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        require(varId <= vars.length, "Wrong varID");

        if (varId == uint(Vars.timeFrame) || varId == uint(Vars.periodMA))

            require(value != 0, "Wrong time frame");

        else

            require(value <= 10000, "Wrong percentage");

        if (varId < vars.length) {

            vars[varId] = value;

            return;

        }

        if (varId == vars.length) {

            feeToPart = value;    // varId = 8

        }

    }



    // set Router contract address

    function setRouter(address _router) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        require(_router != address(0));

        uniV2Router = _router;

        WETH = IDynamicRouter02(uniV2Router).WETH();

        require(WETH != address(0));

    }



    // set fee reimbursement percentage (without decimals)

    function setFeeReimbursement(uint256 percentage) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        require(percentage <= 100, "percentage too high");

        feeReimbursement = percentage;

    }



    // set dynamic token address

    function setDynamic(address _dynamic) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        require(_dynamic != address(0), "Address zero");

        dynamic = _dynamic;

    }



    // set reimbursement contract address for users reimbursements, address(0) to switch of reimbursement

    function setReimbursementContractAndVault(address _reimbursement, address _vault) external {

        require(msg.sender == feeToSetter, 'Dynamic: FORBIDDEN');

        reimbursement = _reimbursement;

        reimbursementVault = _vault;

    }





    function getColletedFees() external view returns (uint256 feeAmount) {

        feeAmount = IERC20(WETH).balanceOf(address(this));

    }



    function claimFee() external returns (uint256) {

        require(msg.sender == feeTo, 'Dynamic: FORBIDDEN');

        uint balance = IERC20(WETH).balanceOf(address(this));

        if (balance != 0) {

            IWETH(WETH).withdraw(balance);

            msg.sender.transfer(address(this).balance);

            //_safeTransfer(WETH, msg.sender, balance);

        }

        return balance;

    }



    receive() external payable {}

}