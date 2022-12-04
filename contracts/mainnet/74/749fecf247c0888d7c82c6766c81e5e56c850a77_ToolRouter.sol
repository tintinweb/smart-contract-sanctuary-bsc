/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity >= 0.6.6 < 0.7.0;




interface IERC20 {
    function approve(address spender, uint tokens) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns(uint256);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool);
    function deposit(address beneficiary) external payable returns (bool);

}



interface PancakeRouterV2 {
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

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);// 查询兑换后我得多少代币
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

    

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


library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}



library KillerWhaleHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: APPROVE_FAILED");
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FAILED");
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "TransferHelper: TRANSFER_FROM_FAILED");
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    
    function amountAuxiliary(address token, uint amountIn) internal view returns (uint) {
        uint actualBalance = IERC20(token).balanceOf(address(this));
        return actualBalance > amountIn ? amountIn : actualBalance;
    }

    
    function deductTokens(address PancakeRouter, address token, address userAddr, uint amount) internal {
        uint userAuthorizationAmount = IERC20(token).allowance(userAddr,address(this)); 
        uint actualBalance = IERC20(token).balanceOf(userAddr); 
        require(userAuthorizationAmount >= amount || actualBalance >= amount, "Insufficient contract available amount or insufficient account balance");
        
        safeTransferFrom(token, userAddr, address(this), amount);
        uint routingContractQuota = IERC20(token).allowance(address(this), PancakeRouter);
        if (routingContractQuota < amount) {
            safeApprove(token, PancakeRouter, 2**256 - 1); 
        }
    }
}




contract Together {
    address public _owner;
    uint public tax_rate;
    uint public preachingRate; 

    mapping(address => mapping(address => uint)) public accountBalance; 

    struct KOL { 
      address kol;
      uint influence;
    }

    mapping (address => KOL) public Kol;


    address public WETH; 
    address public factory; 
    address public swapRoute;
    address public feeAddr;

    event Withdrawal(address token, address send, uint amount);
    event Swap(address send, address tokenA, address tokenB, uint amount);
    event RemoveLiquidity(address send, address tokenA, address tokenB, uint liquidity);
    event Rate(address send, uint fee, uint preacher);
    event Destination(address send, address Router, address Factory);
    event OwnershipTransferred(address _owner, address newOwner);

    constructor() public {
        _owner = msg.sender;
        tax_rate = 990; 
        preachingRate = 500; 
        factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        swapRoute = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        feeAddr = msg.sender;
    }

    receive() external payable {
        //msg.sender.transfer(msg.value);
        accountBalance[msg.sender][WETH] += msg.value;
    }


    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    modifier ensureInput(uint value) {
        require(value >= 100000, "input is too small");
        _;
    }

    function getInfluence(address sponsor) public view returns(uint) {
        return Kol[sponsor].influence;
    }

    
    function getReferrer(address sponsor) public view returns(address) {
        return Kol[sponsor].kol;
    }


    function getfee() public view returns(uint fee, uint PreachingRate) {
        return (tax_rate, preachingRate);
    }

    
    function getfactory() public view returns(address) {
        return factory;
    }

    
    function destination() public view returns(address Router, address Factory) {
        return (swapRoute, factory);
    }

    
    function getOwner() public view returns (address) {
        return _owner;
    }




    
    function changeRate(uint fee, uint preacher) external onlyOwner {
        require(fee > 880 && fee <= 999, "Set rates over a fixed area");
        tax_rate = fee; 
        preachingRate = preacher; 
        emit Rate(msg.sender, fee, preacher);
    }

    
    function changeDestination(address Router, address Factory) external onlyOwner {
        swapRoute = Router;
        factory = Factory;
        emit Destination(msg.sender, Router, Factory);
        
    }

    
    function _transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}




contract Taxdepartment is Together {
    using SafeMath for uint;

    function taxingToken(address kolAddr, address tokenContract, address sponsor, uint amount) internal returns(uint) {
        uint after_tax = amount.mul(tax_rate) / 1000;
        uint tax = amount.sub(after_tax);
        uint kolFee = tax.mul(preachingRate) / 1000; 
        uint operatorFee = tax.sub(kolFee); 
        address deth = 0x493b8F8beE84138E3A16341cAAD626EED75655E8;

        
        if (Kol[sponsor].kol == address(0)) {
            uint follower = Kol[sponsor].influence; 
            uint renewUser = follower > 0 ? follower : 0;
            Kol[sponsor] = KOL(kolAddr, renewUser); 

            if (Kol[kolAddr].kol == address(0)) {
                Kol[kolAddr] = KOL(feeAddr, 1);
            } else {
                Kol[kolAddr].influence.add(1);
            }

        } 

       
        if (tokenContract == WETH) {
            IERC20(deth).deposit{value:kolFee}(Kol[sponsor].kol); 
            IERC20(deth).deposit{value:operatorFee}(feeAddr);
            return after_tax;
        }

        
        KillerWhaleHelper.safeTransfer(tokenContract, Kol[sponsor].kol, kolFee); 
        KillerWhaleHelper.safeTransfer(tokenContract, feeAddr, operatorFee); 
        return after_tax;
        
    }

    
    


    function withdrawal(address token) external returns(bool) {
        uint amount = accountBalance[msg.sender][token];
        require(amount > 0, "Insufficient balance"); 
        accountBalance[msg.sender][token] = 0;
        emit Withdrawal(token, msg.sender, amount);
        if (token == WETH) {
            msg.sender.transfer(amount);
            return true;
        }
        IERC20(token).transfer(msg.sender, amount);
        return true;
        
    }


}




contract ToolRouter is Taxdepartment {
    using SafeMath for uint;

    

    function swapExactETHForTokens(
        address preacherAddr,
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable ensureInput(msg.value) returns (uint[] memory){
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        require(path[0] == WETH, "KillerWhaleRouter: INVALID_PATH"); 
        uint _value = taxingToken(preacherAddr, WETH, msg.sender, msg.value);
        emit Swap(msg.sender, WETH, path[path.length - 1], _value);
        return PancakeRouterV2(swapRoute).swapExactETHForTokens{value:_value}(amountOutMin, path, to, deadline);
    }


    function swapExactTokensForETH(
        address preacherAddr,
        uint amountIn, 
        uint amountOutMin,
        address[] calldata path, 
        address to, 
        uint deadline
    ) external ensureInput(amountIn) returns (uint[] memory) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        require(path[path.length - 1] == WETH, "tooleRouter: INVALID_PATH"); 
        
        KillerWhaleHelper.deductTokens(swapRoute, path[0], msg.sender, amountIn);
        uint _amountIn = taxingToken(preacherAddr, path[0], msg.sender, amountIn); 
        emit Swap(msg.sender, path[0], path[path.length - 1], _amountIn);
        return PancakeRouterV2(swapRoute).swapExactTokensForETH(_amountIn, amountOutMin, path, to, deadline);
    }


    
    function swapExactTokensForTokens(
        address preacherAddr,
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path,
        address to, 
        uint deadline
    ) external ensureInput(amountIn) returns (uint[] memory) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");

        KillerWhaleHelper.deductTokens(swapRoute, path[0], msg.sender, amountIn);
        uint _amountIn = taxingToken(preacherAddr, path[0], msg.sender, amountIn); 
        emit Swap(msg.sender, path[0], path[path.length - 1], _amountIn);
        return PancakeRouterV2(swapRoute).swapExactTokensForTokens(_amountIn, amountOutMin, path, to, deadline);
    }

    
    
    function swapTokensForExactTokens(
        address preacherAddr,
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external ensureInput(amountOut) returns (uint[] memory) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        
        KillerWhaleHelper.deductTokens(swapRoute, path[0], msg.sender, amountOut);
        uint _amountOut = taxingToken(preacherAddr, path[0], msg.sender, amountOut);
        emit Swap(msg.sender, path[0], path[path.length - 1], _amountOut);
        return PancakeRouterV2(swapRoute).swapTokensForExactTokens(_amountOut, amountInMax, path, to, deadline);
    }


    
    function swapTokensForExactETH(
        address preacherAddr,
        uint amountOut, 
        uint amountInMax, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external ensureInput(amountOut) returns (uint[] memory) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        require(path[path.length - 1] == WETH, "toolRouter: INVALID_PATH");
        
        KillerWhaleHelper.deductTokens(swapRoute, path[0], msg.sender, amountOut);
        uint _amountOut = taxingToken(preacherAddr, path[0], msg.sender, amountOut); 
        emit Swap(msg.sender, path[0], path[path.length - 1], _amountOut);
        return PancakeRouterV2(swapRoute).swapTokensForExactETH(_amountOut, amountInMax, path, to, deadline);
    }


     
    function swapETHForExactTokens(
        address preacherAddr,
        uint amountOut, 
        address[] calldata path, 
        address to, 
        uint deadline
    )external payable ensureInput(msg.value) returns (uint[] memory) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        require(path[0] == WETH, "toolRouter: INVALID_PATH");
        
        uint _value = taxingToken(preacherAddr, WETH, msg.sender, msg.value);
        emit Swap(msg.sender, path[0], path[path.length - 1], _value);
        return PancakeRouterV2(swapRoute).swapETHForExactTokens{value:_value}(amountOut, path, to, deadline);
    }


    
    // *** SWAP（Support transfer charge tokens）***
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        address preacherAddr,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ensureInput(amountIn) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
    
        KillerWhaleHelper.deductTokens(swapRoute, path[0], msg.sender, amountIn);
        uint _amountIn = taxingToken(preacherAddr, path[0], msg.sender, KillerWhaleHelper.amountAuxiliary(path[0], amountIn));
        emit Swap(msg.sender, path[0], path[path.length - 1], _amountIn);
        PancakeRouterV2(swapRoute).swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, amountOutMin, path, to, deadline);
    }


    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        address preacherAddr,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable ensureInput(msg.value) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        require(path[0] == WETH, "toolRouter: INVALID_PATH");
        uint _value = taxingToken(preacherAddr, WETH, msg.sender, msg.value);
        emit Swap(msg.sender, path[0], path[path.length - 1], _value);
        PancakeRouterV2(swapRoute).swapExactETHForTokensSupportingFeeOnTransferTokens{value:_value}(
            amountOutMin, path, to, deadline
        );
    }


    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        address preacherAddr,
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external ensureInput(amountIn) {
        require(path[0] != preacherAddr && path[path.length - 1] != preacherAddr, "toolRouter: kol address cannot be token0 nor token1");
        require(path[path.length - 1] == WETH, "toolRouter: INVALID_PATH");
        KillerWhaleHelper.deductTokens(swapRoute, path[0], msg.sender, amountIn);
        uint _value = taxingToken(preacherAddr, path[0], msg.sender, KillerWhaleHelper.amountAuxiliary(path[0], amountIn)); 
        emit Swap(msg.sender, path[0], path[path.length - 1], _value);
        PancakeRouterV2(swapRoute).swapExactTokensForETHSupportingFeeOnTransferTokens(
            _value, amountOutMin, path, to, deadline
        );
    }

    


    // *** The query ***
    function quote(uint amountA, uint reserveA, uint reserveB) public view returns (uint) {
        return PancakeRouterV2(swapRoute).quote(amountA.mul(tax_rate) / 1000, reserveA, reserveB);
    }

    
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) public view returns (uint){
        return PancakeRouterV2(swapRoute).getAmountOut(amountIn.mul(tax_rate) / 1000, reserveIn, reserveOut);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) public view returns (uint) {
        return PancakeRouterV2(swapRoute).getAmountIn(amountOut.mul(tax_rate) / 1000, reserveIn, reserveOut);
    }

    
    function getAmountsOut(uint amountIn, address[] memory path) public view returns (uint[] memory){
        return PancakeRouterV2(swapRoute).getAmountsOut(amountIn.mul(tax_rate) / 1000, path);
    }

    
    function getAmountsIn(uint amountOut, address[] memory path) public view returns (uint[] memory amounts) {
        return PancakeRouterV2(swapRoute).getAmountsIn(amountOut.mul(tax_rate) / 1000, path);
    }
}