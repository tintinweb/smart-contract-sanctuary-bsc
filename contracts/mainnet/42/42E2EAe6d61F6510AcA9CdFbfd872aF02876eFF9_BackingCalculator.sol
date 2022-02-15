/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

interface IERC20 {
    function decimals() external view returns(uint8);
    function balanceOf(address owner) external view returns(uint);
}

interface IPair is IERC20{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

interface IHXLCirculation{
    function HXLCirculatingSupply() external view returns ( uint );
}

interface IBackingCalculator{
    //decimals for backing is 4
    function backing() external view returns (uint _lpBacking, uint _treasuryBacking);

    //decimals for backing is 4
    function lpBacking() external view returns(uint _lpBacking);

    //decimals for backing is 4
    function treasuryBacking() external view returns(uint _treasuryBacking);

    //decimals for backing is 4
    function backing_full() external view returns (
        uint _lpBacking, 
        uint _treasuryBacking,
        uint _totalStableReserve,
        uint _totalHXLReserve,
        uint _totalStableBal,
        uint _cirulatingHXL
    );
}
contract BackingCalculator is IBackingCalculator{
    using SafeMath for uint;
    IPair public busdlp=IPair(0xC94364D0FFD3c015689f55e167AC359eB93c617E);
    IPair public usdtlp=IPair(0xF3CEDC727098e7f812c3b5B227C022B0CD8A48B1);
    // IPair public usdclp=IPair(0x3541B43FEBE2Dcbb8d9af01b533eC20b7fcf4A28);
    // IPair public dailp=IPair(0x2285bD77fA0788C7b12e03ACF1e4ea94006f77B7);
    IERC20 public busd=IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    IERC20 public usdt=IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 public usdc=IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
    IERC20 public dai=IERC20(0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3);
    address public HXL=0x57612D60B415ad812Da9a7cF5672084796A4aB81;
    address public treasury=0xC06A7e21289E35eA94cE67C0f7AfAD4e972117D8;
    IHXLCirculation public HXLCirculation=IHXLCirculation(0xd9149c6A0F3918903b6b801065E2613050729c0F);

    function backing() external view override returns (uint _lpBacking, uint _treasuryBacking){
        (_lpBacking,_treasuryBacking,,,,)=backing_full();
    }

    function lpBacking() external view override returns(uint _lpBacking){
        (_lpBacking,,,,,)=backing_full();
    }

    function treasuryBacking() external view override returns(uint _treasuryBacking){
        (,_treasuryBacking,,,,)=backing_full();
    }

    //decimals for backing is 4
    function backing_full() public view override returns (
        uint _lpBacking, 
        uint _treasuryBacking,
        uint _totalStableReserve,
        uint _totalHXLReserve,
        uint _totalStableBal,
        uint _cirulatingHXL
    ){
        // lp
        uint stableReserve;
        uint HXLReserve;
        //dailp
        // (HXLReserve,stableReserve)=HXLStableAmount(dailp);
        // _totalStableReserve=_totalStableReserve.add(stableReserve);
        // _totalHXLReserve=_totalHXLReserve.add(HXLReserve);
        //busdlp
        (HXLReserve,stableReserve)=HXLStableAmount(busdlp);
        _totalStableReserve=_totalStableReserve.add(stableReserve);
        _totalHXLReserve=_totalHXLReserve.add(HXLReserve);
        //usdtlp
        (HXLReserve,stableReserve)=HXLStableAmount(usdtlp);
        _totalStableReserve=_totalStableReserve.add(stableReserve);
        _totalHXLReserve=_totalHXLReserve.add(HXLReserve);
        //usdclp
        // (HXLReserve,stableReserve)=HXLStableAmount(usdclp);
        // _totalStableReserve=_totalStableReserve.add(stableReserve);
        // _totalHXLReserve=_totalHXLReserve.add(HXLReserve);
        _lpBacking=_totalStableReserve.div(_totalHXLReserve).div(1e5);

        //treasury
        _totalStableBal=_totalStableBal.add(toE18(dai.balanceOf(treasury),dai.decimals()));
        _totalStableBal=_totalStableBal.add(toE18(usdc.balanceOf(treasury),usdc.decimals()));
        _totalStableBal=_totalStableBal.add(toE18(usdt.balanceOf(treasury),usdt.decimals()));
        _totalStableBal=_totalStableBal.add(toE18(busd.balanceOf(treasury),busd.decimals()));
        _cirulatingHXL=HXLCirculation.HXLCirculatingSupply().sub(_totalHXLReserve);
        _treasuryBacking=_totalStableBal.div(_cirulatingHXL).div(1e5);
    }
    function HXLStableAmount( IPair _pair ) public view returns ( uint HXLReserve,uint stableReserve){
        ( uint reserve0, uint reserve1, ) =  _pair .getReserves();
        uint8 stableDecimals;
        if ( _pair.token0() == HXL ) {
            HXLReserve=reserve0;
            stableReserve=reserve1;
            stableDecimals=IERC20(_pair.token1()).decimals();
        } else {
            HXLReserve=reserve1;
            stableReserve=reserve0;
            stableDecimals=IERC20(_pair.token0()).decimals();
        }
        stableReserve=toE18(stableReserve,stableDecimals);
    }
    
    function toE18(uint amount, uint8 decimals) public pure returns (uint){
        if(decimals==18)return amount;
        else if(decimals>18) return amount.div(10**(decimals-18));
        else return amount.mul(10**(18-decimals));
    }
}