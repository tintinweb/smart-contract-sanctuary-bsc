//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Interfaces.sol";
import "./Libraries.sol";

interface IPancakeCallee {
    function pancakeCall(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

interface ITOKEN is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}

abstract contract FlashLoanReceiverBase is IFlashLoanReceiver {
  using SafeERC20 for IERC20;

  ILendingPoolAddressesProvider public immutable ADDRESSES_PROVIDER;
  ILendingPool public immutable LENDING_POOL;

  constructor(ILendingPoolAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
    LENDING_POOL = ILendingPool(provider.getLendingPool());
  }
}


contract ArbitragePro is FlashLoanReceiverBase, IPancakeCallee {
    
    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);

    mapping(bytes32 => mapping(address => bool)) public roles;

    bytes32 private constant OWNER = keccak256(abi.encodePacked("OWNER"));
    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));

    // BSC Testnet
    ITOKEN private constant WBNB = ITOKEN(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd);
    address private constant PANCAKE_V2_Factory = address(0x6725F303b657a9451d8BA641348b6761A6CC7a17);
    
    // BSC mainnet
    address private constant BUSD = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    // ITOKEN private constant WBNB = ITOKEN(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    // address private constant PANCAKE_V2_Factory = address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address private constant BNB_address = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    
    
    modifier permitRole(bytes32 _role) {
        require(roles[_role][msg.sender], "Not Authorized");
        _;
    }

    // modifier onlyExecutor() {
    //     require(msg.sender == executor);
    //     _;
    // }

    // modifier onlyOwner() {
    //     require(msg.sender == owner);
    //     _;
    // }

    constructor(address _executor, address _collector, ILendingPoolAddressesProvider _addressProvider) FlashLoanReceiverBase(_addressProvider) payable {
        _grantRole(OWNER, msg.sender);
        _grantRole(ADMIN, _collector);
        _grantRole(USER, _executor);
 
        if (msg.value > 0) {
            WBNB.deposit{value: msg.value}();
        }
    }

    // The next 3 functions are set for Access Control

    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;
        emit GrantRole(_role, _account);
    }

    function grantRole(bytes32 _role, address _account) external permitRole(ADMIN) permitRole(OWNER){
        _grantRole(_role, _account);
        emit GrantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) external permitRole(ADMIN) permitRole(OWNER){
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }

    function call(address payable _to, uint256 _value, bytes calldata _data) external permitRole(OWNER) payable returns (bytes memory) {
        require(_to != address(0));
        (bool _success, bytes memory _result) = _to.call{value: _value}(_data);
        require(_success);
        return _result;
    }

    function withdraw(address token) external permitRole(ADMIN) {
        if (token == BNB_address) {
            uint256 bal = address(this).balance;
            payable(msg.sender).transfer(bal);
        } else if (token != BNB_address) {
            uint256 bal = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(payable(address(msg.sender)), bal);
        }
    }

    receive() external payable {
    }

    function optimal_add(uint x) private pure returns (uint) {
        unchecked {
            return ++x;
        }
    }

    function getAmountOutMin(
        uint256 _amountIn, 
        address[] calldata _tokens, 
        address _dexRouterContractAddress
    ) external view returns (uint256) {
       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WBNB, tokenOut]
       //the if statement below takes into account if token in or token out is WBNB.  then the path is only 2 addresses
        address[] memory path;
        uint256 i = 0;
        uint256 len = _tokens.length;
        for (i; i < len; i = optimal_add(i)) {
            path[i] = address(_tokens[i]);
        }
        
        uint256[] memory amountOutMins = IUniswapV2Router(_dexRouterContractAddress).getAmountsOut(_amountIn, path);
        return amountOutMins[amountOutMins.length - 1];  
    }

    function multiSingleSwapFLParams(
        uint256 _amountToFirstMarket, 
        bytes memory _params, 
        uint256 totalLoanDebt
    ) internal {
        ( , uint256 _bnbAmountToCoinbase, address[] memory _targets, bytes[] memory _payloads, , address payable _dexRouterContractAddress, address payable _baseToken) = abi.decode(_params, (uint256, uint256, address[], bytes[], address[], address, address));
        require(_targets.length == _payloads.length);
        IERC20 baseToken = IERC20(_baseToken);
        baseToken.transfer(_targets[0], _amountToFirstMarket);
        uint256 i = 0;
        uint256 len = _targets.length;
        for (i; i < len; optimal_add(i)) {
            (bool _success, ) = _targets[i].call(_payloads[i]);
            require(_success); 
        }

        uint256 _token0BalanceAfter = WBNB.balanceOf(address(this));
        require(_token0BalanceAfter > totalLoanDebt + _bnbAmountToCoinbase);

        
        if (_baseToken == address(WBNB)) {
            uint256 _bnbBalance = address(this).balance;
            if (_bnbBalance < _bnbAmountToCoinbase) {
                WBNB.withdraw(_bnbAmountToCoinbase - _bnbBalance);
            }
        } else { 
            baseToken.approve(_dexRouterContractAddress, _bnbAmountToCoinbase);
            address[] memory path = new address[](2);
            path[0] = address(_baseToken);
            path[1] = address(WBNB);
            // check next line for correct implementation 
            (uint256[] memory _amountOutMin) = IUniswapV2Router(_dexRouterContractAddress).getAmountsOut(_bnbAmountToCoinbase, path);
            // doublecheck the _amountOutMin[0] to see which is the correct output.
            IUniswapV2Router(_dexRouterContractAddress).swapExactTokensForTokens(_bnbAmountToCoinbase, (_amountOutMin[0] * 80) / 100  , path, payable(address(this)), block.timestamp);
            WBNB.withdraw(_amountOutMin[0]);
        }

        if (_bnbAmountToCoinbase > 0) {
            if (_baseToken == address(WBNB)) {
                uint256 _bnbBalance = address(this).balance;
                if (_bnbBalance < _bnbAmountToCoinbase) {
                    WBNB.withdraw(_bnbAmountToCoinbase - _bnbBalance);
                }
            } else {
                baseToken.approve(_dexRouterContractAddress, _bnbAmountToCoinbase);
                
                uint256 slippage = totalLoanDebt > 0 ? block.timestamp : block.timestamp + 100;
                address[] memory path = new address[](2);
                path[0] = address(_baseToken);
                path[1] = address(WBNB);
                
                // check next line for correct implementation 
                uint256[] memory _amountOutWBNB = IUniswapV2Router(_dexRouterContractAddress).getAmountsOut(_bnbAmountToCoinbase, path);
                IUniswapV2Router(_dexRouterContractAddress).swapExactTokensForTokens(_bnbAmountToCoinbase, (_amountOutWBNB[0] * 80) / 100, path, payable(address(this)), slippage);
                WBNB.withdraw(_amountOutWBNB[0]);
            }
            (bool _success, ) = payable(block.coinbase).call{value: _bnbAmountToCoinbase}(new bytes(0));
            require(_success);
        }
    }

    function multiCyclicFLParams(
        uint256 _amountToFirstExchange, 
        bytes memory _params, 
        uint256 totalLoanDebt
    ) internal {
        ( , uint256 _bnbAmountToCoinbase, address[] memory _targets, bytes[] memory _payloads, , , address[] memory _dexRouterContractAddress, address[][] memory _routerTokens) = abi.decode(_params, (uint256, uint256, address[], bytes[], address[], address[], address[], address[][]));
        require(_targets.length == _payloads.length);

        //                _________________________     _________________________
        //               [dex0inputToken, dex0path]  |  [dex1inputToken, dex1path]
        //                            | ___________  |  __________ |
        // _token param structure is: [ [a, [a,b,c] ], [c, [c,d,a] ] ]
        uint256 j = 0;
        uint256 len = _targets.length;
        uint256[] memory _amountOutMin;
        address baseToken = address(_routerTokens[0][0]);
        for (j; j < len; optimal_add(j)) {
            if ( j == 0 && baseToken == address(WBNB)) {
                IERC20(baseToken).approve(_dexRouterContractAddress[0], _amountToFirstExchange);
            } else if (j == 0 && baseToken != address(WBNB)) {
                IERC20(baseToken).approve(_dexRouterContractAddress[0], _amountToFirstExchange + _bnbAmountToCoinbase); 
            } else if (j > 0) {
                // Check parameter Types specially amountOutMin
                _amountOutMin = IUniswapV2Router(_dexRouterContractAddress[--j]).getAmountsOut(j < 2 ? _amountToFirstExchange: _amountOutMin[_amountOutMin.length-1], _routerTokens[--j]);
                IERC20(_routerTokens[j][0]).approve(_dexRouterContractAddress[j], _amountOutMin[_amountOutMin.length-1] );
            }

            (bool _success, ) = _targets[j].call(_payloads[j]);
            require(_success); 
        }

        uint256 _tokenBalanceAfter = IERC20(baseToken).balanceOf(address(this));
        require(_tokenBalanceAfter > totalLoanDebt + _bnbAmountToCoinbase);
        
        if (_bnbAmountToCoinbase > 0) {
            if (baseToken == address(WBNB)) {
                uint256 _bnbBalance = address(this).balance;
                if (_bnbBalance < _bnbAmountToCoinbase) {
                    WBNB.withdraw(_bnbAmountToCoinbase - _bnbBalance);
                }
            } else {
                IERC20(baseToken).approve(_dexRouterContractAddress[0], _bnbAmountToCoinbase);
                
                uint256 slippage = totalLoanDebt > 0 ? block.timestamp : block.timestamp + 100;
                address[] memory path = new address[](2);
                path[0] = address(baseToken);
                path[1] = address(WBNB);
                
                uint256[] memory _amountOutWBNB = IUniswapV2Router(_dexRouterContractAddress[0]).getAmountsOut(_bnbAmountToCoinbase, path);
                IUniswapV2Router(_dexRouterContractAddress[0]).swapExactTokensForTokens(_bnbAmountToCoinbase, (_amountOutWBNB[0] * 80) / 100, path, payable(address(this)), slippage);
                WBNB.withdraw(_amountOutWBNB[0]);
            }
            payable(block.coinbase).transfer(_bnbAmountToCoinbase);
        }
    }

    /* 
        Multiplier Finance Flashloan
    */

    function flashloanAave(address borrowedTokenAddress, uint256 amountToBorrow, bytes calldata _params) external permitRole(USER) {
        address receiverAddress = payable(address(this));

        address[] memory assets = new address[](1);
        assets[0] = borrowedTokenAddress;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amountToBorrow;

        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;

        address onBehalfOf = address(this);
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            _params,
            referralCode
        );
    }

    function executeOperation(
        address[] calldata /* assets */,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address /* initiator */,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        uint amountOwing = amounts[0] + premiums[0];
        (uint256 cycleType, , , , address[] memory _tokens, , , address[][] memory _routerTokens) = abi.decode(params, (uint256, uint256, address[], bytes[], address[], address[], address[], address[][]));
        
        if (cycleType == 0) {
            multiSingleSwapFLParams(amounts[0], params, amountOwing);
            IERC20(_tokens[0]).approve(address(LENDING_POOL), amountOwing);
        } else if (cycleType == 1) {
            multiCyclicFLParams(amounts[0], params, amountOwing);
            IERC20(_routerTokens[0][0]).approve(address(LENDING_POOL), amountOwing);
        }
        
        return true;
    }

    /* 
        PancakeSwap Flashloan
    */

    function flashloanUniswap(address borrowedTokenAddress, uint256 amountToBorrow, bytes memory _params) external permitRole(USER) {

        address pair;
        if (borrowedTokenAddress == address(WBNB) || borrowedTokenAddress == address(BUSD)) {
            // WBNB-BUSD
            pair = address(0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16);
        } else {
            pair = IUniswapV2Factory(PANCAKE_V2_Factory).getPair(borrowedTokenAddress, address(WBNB));
            require(pair != address(0), "!pair");
        }
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint amount0Out = borrowedTokenAddress == token0 ? amountToBorrow : 0;
        uint amount1Out = borrowedTokenAddress == token1 ? amountToBorrow : 0;
        

        bytes memory data = abi.encode(borrowedTokenAddress, amountToBorrow, _params);

        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function pancakeCall(
        address _sender,
        uint /* _amount0 */,
        uint /* _amount1 */,
        bytes calldata _data
    ) external override {
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(PANCAKE_V2_Factory).getPair(token0, token1);

        require(msg.sender == pair, "!pair");
        require(_sender == address(this), "!sender");

        (address borrowedTokenAddress, uint amountToBorrow, bytes memory _params) = abi.decode(_data, (address, uint, bytes));

        uint fee = ((amountToBorrow * 3) / 997) + 1;
        uint amountToRepay = amountToBorrow + fee;

        // Action
        (uint256 cycleType, , , , , , , ) = abi.decode(_params, (uint256, uint256, address[], bytes[], address[], address[], address[], address[][]));
        
        if (cycleType == 0) {
            multiSingleSwapFLParams(amountToBorrow, _params, amountToRepay);
        } else if (cycleType == 1) {
            multiCyclicFLParams(amountToBorrow, _params, amountToRepay);
        }

        IERC20(borrowedTokenAddress).transfer(pair, amountToRepay);
    }
}