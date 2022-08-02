/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}
interface IERC20 {
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint);
    function burn(uint amount) external returns (bool);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
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


contract Ownable {
    address internal owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: You are not the Owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract MOMaster is Ownable {

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    IERC20 public USDT;
    IERC20 public MO;

    address private _adminAccount;

    uint public usdtAmount = 200 * 1e18;

    mapping(address => address) public parent;

    modifier onlyAdmin() {
        require(msg.sender == _adminAccount, "Admin: caller is not the admin");
        _;
    }
    
    constructor(address _usdtAddress, address _moAddress, address _adminAccount_ , address swapRouter) {
        USDT = IERC20(_usdtAddress);
        MO = IERC20(_moAddress);
        _adminAccount = _adminAccount_;
        parent[address(0x1Bf5fd82731Dde2e8231ADf091FaeBD22530988d)] = address(0x1Bf5fd82731Dde2e8231ADf091FaeBD22530988d);
        parent[address(0x7EB6059ab51356f15ecC7FC26dB745392ae67592)] = address(0x7EB6059ab51356f15ecC7FC26dB745392ae67592);
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(swapRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            _moAddress,
            _usdtAddress
        );
        uniswapV2Router = _uniswapV2Router;
    }

    function setAdminAccount(address _account) external onlyOwner{
        _adminAccount = _account;
    }

    function setParticipateAmount(uint _amount) external onlyOwner{
        usdtAmount = _amount;
    }

    function participate(address _inviter) external {
      
        require(USDT.balanceOf(msg.sender) >= usdtAmount, "The account USDT balance is insufficient");
        
        if(parent[msg.sender] == address(0)) {
            require(parent[_inviter] != address(0), "Invalid inviter");
        }

        if(_inviter != address(0) && parent[msg.sender] == address(0)) {
            parent[msg.sender] = _inviter;
        } else {
            require(parent[msg.sender] != address(0) , "Inviter not bound");
        }

        uint dAmount = 100 * 1e18;

        USDT.transferFrom(msg.sender, address(this), usdtAmount);

        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(MO);

        TransferHelper.safeApprove(address(USDT), address(uniswapV2Router), dAmount);

        uint moBlance = MO.balanceOf(address(this));

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(dAmount, 0, path, address(this), block.timestamp);

        uint newMO = MO.balanceOf(address(this));
        uint swapMO =  newMO - moBlance;

        MO.burn(swapMO);
     
        emit participateLogs(20, msg.sender, _inviter, usdtAmount,swapMO, block.timestamp);
    }

    function checkInviter(address _account) public view returns(bool) {

        return parent[_account] != address(0);

    }
    
    function withdraw(address _tokenAddress, address _account, uint _amount) external onlyAdmin {

        uint balance = IERC20(_tokenAddress).balanceOf(address(this));

        require(_amount > 0, "Withdrawal quantity must be greater than zero");

        require(balance >= _amount, "Contract balance is insufficient");

        IERC20(_tokenAddress).transfer(_account, _amount);

        emit withdrawLogs(10, _tokenAddress, _account, _amount, block.timestamp);
    }


    function withdrawPayment(address _tokenAddress, uint _orderId, address _account, uint _amount) external onlyAdmin {

        uint balance = IERC20(_tokenAddress).balanceOf(address(this));

        require(_amount > 0, "Withdrawal quantity must be greater than zero");

        require(balance >= _amount, "Contract balance is insufficient");

        IERC20(_tokenAddress).transfer(_account, _amount);

        emit withdrawPaymentLogs(11, _orderId, _tokenAddress, _account, _amount, block.timestamp);
    }


    event withdrawLogs(uint indexed _type, address _tokenAddress, address _withdrawAccount, uint _withdrawCount, uint _withdrawTime);

    event withdrawPaymentLogs(uint indexed _type, uint _orderId, address _tokenAddress, address _withdrawAccount, uint _withdrawCount, uint _withdrawTime);

    event participateLogs(uint indexed _type, address _account, address _inviter, uint _usdtAmount, uint _mo, uint _time);

}