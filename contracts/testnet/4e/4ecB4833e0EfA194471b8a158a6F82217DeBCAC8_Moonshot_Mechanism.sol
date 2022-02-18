/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

// File: contracts/interfaces/IERC20.sol



pragma solidity >=0.5.0;

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
}

// File: contracts/interfaces/IPYESwapRouter01.sol



pragma solidity >=0.6.2;

interface IPYESwapRouter01 {
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
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: contracts/interfaces/IPYESwapRouter.sol



pragma solidity >=0.6.2;


interface IPYESwapRouter is IPYESwapRouter01 {
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
    function pairFeeAddress(address pair) external view returns (address);
    function adminFee() external view returns (uint256);
    function feeAddressGet() external view returns (address);
}

// File: contracts/Moonshot.sol


pragma solidity ^0.8.0;



contract Moonshot_Mechanism {

    struct Moonshot {
        string Name;
        uint Value;
    }

    Moonshot[] internal Moonshots;
    uint[] internal mysteryMoonshots = [250, 500, 750, 1000, 2000];
    address admin;
    uint disbursalThreshold;

    bool private inSwap;
    modifier swapping() { inSwap = true; _; inSwap = false; }
    IPYESwapRouter public pyeSwapRouter;
    address public FORCE;
    address public WBNB;

    constructor(address _router, address _FORCE) {
        pyeSwapRouter = IPYESwapRouter(_router);
        FORCE = _FORCE;
        WBNB = pyeSwapRouter.WETH();

        admin = msg.sender;
        Moonshots.push(Moonshot("Waxing", 250));
        Moonshots.push(Moonshot("Waning", 500));
        Moonshots.push(Moonshot("Half Moon", 750));
        Moonshots.push(Moonshot("Full Moon", 1000));
        Moonshots.push(Moonshot("Blue Moon", 2000));
        Moonshots.push(Moonshot("Mystery Moonshot", 0));
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
    //-------------------------- BEGIN EDITING FUNCTIONS ----------------------------------

    // Allows admin to create a new moonshot with a corresponding value; pushes new moonshot to end of array and increases array length by 1.
    function createMoonshot(string memory _newName, uint _newValue) public onlyAdmin {
        Moonshots.push(Moonshot(_newName, _newValue));
    }
    // Remove last element from array; this will decrease the array length by 1.
    function popMoonshot() public onlyAdmin {
        Moonshots.pop();
    }
    // Delete does not change the array length. It resets the value at index to its default value of 0.
    function deleteMoonshot(uint _index) public {
        delete Moonshots[_index];
    }
    //-------------------------- BEGIN GETTER FUNCTIONS ----------------------------------

    function getMoonshots() public view returns (Moonshot[] memory) {
        Moonshot[] storage result = Moonshots;
        return result;
    }

    function getContractValue() public view onlyAdmin returns (uint) {
        return address(this).balance;
    }
    //-------------------------- BEGIN MOONSHOT SELECTION FUNCTIONS ----------------------------------
    // Generates a "random" number.
    function random() internal view onlyAdmin returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty + block.timestamp)));
    }

    function pickMoonshot() public onlyAdmin {
        uint disbursalValue;
        uint mysteryValue;
        Moonshot storage winningStruct = Moonshots[random() % Moonshots.length];
        disbursalValue = winningStruct.Value;
        
        if (disbursalValue == 0) { 
            mysteryValue = mysteryMoonshots[random() % Moonshots.length];
            disbursalThreshold = mysteryValue;
        } else {
            disbursalThreshold = disbursalValue;
        }
    }

    function shootMoon() public {
        uint256 moonBalance = IERC20(address(WBNB)).balanceOf(address(this));
        require(moonBalance >= disbursalThreshold * (10**9)); 
        buyReflectTokens(disbursalThreshold, address(this));
    }

    function buyReflectTokens(uint256 amount, address to) internal swapping {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = FORCE;

        pyeSwapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            to,
            block.timestamp
        );
        pickMoonshot();
    }
    
   








}