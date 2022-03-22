/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Router01 {
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

interface GVToken is IERC20  {
    function minTokenOfInviterReward() external view returns (uint256);
    function inviter(address account) external view returns (address);
}

contract GlobalVillageLottery is Ownable {
    using SafeMath for uint256;

    uint256 public marketingFee = 3;
    uint256 public superNodeFee = 2;
    uint256 public technologyFee = 1;
    uint256 public fundFee = 2;
    uint256 public nodeFee = 2;
    uint256 public inviterFee = 10;

    address public marketingWallet;
    address public superNodeWallet;
    address public technologyWallet;
    address public fundWallet;
    address public nodeWallet;

    address public liquidityWallet;

    uint256 public Jackpot;
    GVToken  public token;

    mapping (address => bool) public _isOldUser;

    mapping (uint256 => mapping (uint256 => uint256)) public luckAmount;

    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0xB6BA90af76D139AB3170c7df0139636dB6120F7e);

    constructor(
        address liquidityWallet_,
        address marketingWallet_,
        address  superNodeWallet_,
        address  technologyWallet_,
        address  fundWallet_,
        address  nodeWallet_,
        address token_
    )  {
        liquidityWallet = liquidityWallet_;
        marketingWallet = marketingWallet_;
        superNodeWallet = superNodeWallet_;
        technologyWallet = technologyWallet_;
        fundWallet = fundWallet_;
        nodeWallet = nodeWallet_;
        token = GVToken(token_);
    }

    receive() external payable {
        uint256 amount = msg.value;
        
        // 20%按比例分配
        uint256 originAmount = amount;

        uint256 MFee = originAmount.mul(marketingFee).div(100);    
        if(MFee > 0){
            payable(marketingWallet).transfer(MFee);
            amount = amount.sub(MFee);
        }
        
        uint256 SNFee = originAmount.mul(superNodeFee).div(100);    
        if(SNFee > 0){
            payable(superNodeWallet).transfer(SNFee);
            amount = amount.sub(SNFee);
        }

        uint256 TFee = originAmount.mul(technologyFee).div(100);    
        if(TFee > 0){
            payable(technologyWallet).transfer(TFee);
            amount = amount.sub(TFee);
        }

        uint256 FFee = originAmount.mul(fundFee).div(100);    
        if(FFee > 0){
            payable(fundWallet).transfer(FFee);
            amount = amount.sub(FFee);
        }

        uint256 NFee = originAmount.mul(nodeFee).div(100);    
        if(NFee > 0){
            payable(nodeWallet).transfer(NFee);
            amount = amount.sub(NFee);
        }

        (uint256 IFeeAmount, uint256 IFeeCurrent) = takeInviter(_msgSender(), originAmount);
        if(IFeeCurrent > 0){
            payable(fundWallet).transfer(IFeeCurrent);
        }
        amount = amount.sub(IFeeAmount);

        if(originAmount != 3 * 10**16){
            Jackpot = Jackpot.add(amount);
            return;
        }

        // 50%添加流动性
        uint256 liquidity =  originAmount.mul(50).div(100);
        payable(liquidityWallet).transfer(liquidity);
        amount = amount.sub(liquidity);

        // 30%进入奖池
        Jackpot = Jackpot.add(amount);

        if(!_isOldUser[_msgSender()]){
            token.transfer(_msgSender(), 100 * 10 **18);
            _isOldUser[_msgSender()] = true;
            return;
        }

        uint256 bnbReward;
        uint256 roundWinningNumbers = generateRandomNumber();
        uint256 thisDay = block.timestamp.div(86400);
        if(roundWinningNumbers <= 73314){
            token.transfer(_msgSender(), 50 * 10 **18);
            return;
        }else if(roundWinningNumbers <= 98314){
            token.transfer(_msgSender(), 150 * 10 **18);
            return;
        }else if(roundWinningNumbers <= 99314){
            if(luckAmount[thisDay][3] < 100){
                luckAmount[thisDay][3] += 1;
                bnbReward = 3 * 10 ** 16;
            }
        }else if(roundWinningNumbers <= 99814){
            if(luckAmount[thisDay][6] < 50){
                luckAmount[thisDay][6] += 1;
                bnbReward = 6 * 10 ** 16;
            }
        }else if(roundWinningNumbers <= 99914){
            if(luckAmount[thisDay][15] < 20){
                luckAmount[thisDay][15] += 1;
                bnbReward = 15 * 10 ** 16;
            }
        }else if(roundWinningNumbers <= 99964){
            if(luckAmount[thisDay][30] < 10){
                luckAmount[thisDay][30] += 1;
                bnbReward = 30 * 10 ** 16;
            }
        }else if(roundWinningNumbers <= 99989){
            if(luckAmount[thisDay][60] < 5){
                luckAmount[thisDay][60] += 1;
                bnbReward = 60 * 10 ** 16;
            }
        }else if(roundWinningNumbers <= 99999){
            if(luckAmount[thisDay][150] < 2){
                luckAmount[thisDay][150] += 1;
                bnbReward = 150 * 10 ** 16;
            }
        }else if(roundWinningNumbers == 100000){
            if(luckAmount[thisDay][300] < 1){
                luckAmount[thisDay][300] += 1;
                bnbReward = 300 * 10 ** 16;
            }
        }

        if(bnbReward == 0 ||bnbReward >= Jackpot){
            token.transfer(_msgSender(), 50 * 10 **18);
            return;
        }
        
        payable(_msgSender()).transfer(bnbReward);
        Jackpot = Jackpot.sub(bnbReward);
    }

    function generateRandomNumber() internal view returns (uint256) {
        uint256 _amount = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, Jackpot, block.gaslimit)
            )
        );
        uint256 _saltByUniswapV2Router = generateRandomNumberFromUniswapV2Router(
                _amount.mod(100).add(1) * (10**16)
            );
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.number,
                    block.timestamp,
                    gasleft(),
                    _saltByUniswapV2Router
                )
            )
        );
        return randomNumber.mod(100000).add(1);
    }

    function generateRandomNumberFromUniswapV2Router(uint256 amount)
        internal
        view
        returns (uint256)
    {
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = 0xEdA5dA0050e21e9E34fadb1075986Af1370c7BDb;
        uint256[] memory amounts = uniswapV2Router.getAmountsOut(amount, path);
        uint256 temp;
        for (uint256 i = 0; i < amounts.length; i++) {
            temp = temp.add(amounts[i]);
        }
        return temp;
    }

    function takeInviter(address from, uint256 amount) private returns(uint256,uint256)  {
            uint256 IFeeAmount = amount.mul(inviterFee).div(100);
            uint256 IFeeCurrent = IFeeAmount;
            if (IFeeAmount > 0){
                    address cur = from;
                    for (int256 i = 0; i < 10; i++) {
                        uint256 rate;
                        if (i == 0) {
                            rate = 250;
                        } else if(i == 1 ){
                            rate = 200;
                        } else if(i == 2 ){
                            rate = 150;
                        } else if(i == 3 ){
                            rate = 100;
                        } else {
                            rate = 50;
                        } 
                        cur = token.inviter(cur);
                        if (cur == address(0)) {
                            break;
                        }
                        if (token.balanceOf(cur) < token.minTokenOfInviterReward()) {
                            continue;
                        }
                        uint256 curTAmount = amount.mul(rate).div(10000);
                        if(IFeeCurrent < curTAmount) curTAmount = IFeeCurrent;
                        if(curTAmount > 0) payable(cur).transfer(curTAmount);
                        IFeeCurrent = IFeeCurrent.sub(curTAmount);
                    }
            }
            return (IFeeAmount,IFeeCurrent);
    }

    function setLiquidityWallet(address  wallet) external onlyOwner{
        liquidityWallet = wallet;
    }
    function setMarketingWallet(address  wallet) external onlyOwner{
        marketingWallet = wallet;
    }
    function setSuperNodeWallet(address  wallet) external onlyOwner{
        superNodeWallet = wallet;
    }
    function setTechnologyWallet(address  wallet) external onlyOwner{
        technologyWallet = wallet;
    }
    function setFundWallet(address  wallet) external onlyOwner{
        fundWallet = wallet;
    }
    function setNodeWallet(address  wallet) external onlyOwner{
        nodeWallet = wallet;
    }
    function setMarketingFee(uint256 amount) public onlyOwner {
        marketingFee = amount;
    }
    function setSuperNodeFee(uint256 amount) public onlyOwner {
        superNodeFee = amount;
    }
    function setTechnologyFee(uint256 amount) public onlyOwner {
        technologyFee = amount;
    }
    function setFundFee(uint256 amount) public onlyOwner {
        fundFee = amount;
    }
    function setNodeFee(uint256 amount) public onlyOwner {
        nodeFee = amount;
    }
    function setToken(address token_) public onlyOwner {
        token = GVToken(token_);
    }

    function withdrawETH(address account, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount , "BAD");
        payable(account).transfer(amount);
    }

    function withdrawAnyToken(address addr, address account, uint256 amount) public onlyOwner {
        require(IERC20(addr).balanceOf(address(this)) >= amount , "BAD");
        IERC20(addr).transfer(account, amount);
    }

}