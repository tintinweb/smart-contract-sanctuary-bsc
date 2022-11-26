/**
 * @title ZAP
 * @dev ZAP
 *
 * @author - <USDFI TRUST>
 * for the USDFI Trust
 *
 * SPDX-License-Identifier: Business Source License 1.1
 * 
 **/

import "./Ownable.sol";
import "./ReentrancyGuard.sol";
import "./IWombatRouter.sol";
import "./IRouter2.sol";
import "./IVault.sol";
import "./IDynamicPool.sol";
import "./IWBNB.sol";


pragma solidity 0.6.12;
/**
 * @dev Implementation of a vault to deposit funds for yield optimizing.
 * This is the contract that receives funds and that users interface with.
 * The yield optimizing strategy itself is implemented in a separate 'Strategy.sol' contract.
 */
contract Zap1 is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    address public nativ = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public aBNBc = 0xE85aFCcDaFBE7F2B096f268e31ccE3da8dA2990A;

    address public vault;

    address[] public tokenPath = [nativ, aBNBc];
    address[] public tokenPathBack = [aBNBc, nativ];
    address[] public poolPath = [0x0029b7e8e9eD8001c868AA09c74A1ac6269D4183];
    address public wombatRouter = 0x19609B03C976CCA288fbDae5c21d4290e9a4aDD7;

    address[] public pfad;

    address public want = 0x9d2deaD9547EB65Aa78E239647a0c783f296406B;

    address public PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

//------------------

   constructor(

    )  public {
        _giveAllowances();
    }

//------------------

   function _giveAllowances() internal {
    IERC20(nativ).safeApprove(wombatRouter, 0);
    IERC20(nativ).safeApprove(wombatRouter, uint256(-1));

    IERC20(aBNBc).safeApprove(wombatRouter, 0);
    IERC20(aBNBc).safeApprove(wombatRouter, uint256(-1));

    IERC20(aBNBc).safeApprove(poolPath[0], 0);
    IERC20(aBNBc).safeApprove(poolPath[0], uint256(-1));

    IERC20(want).safeApprove(poolPath[0], 0);
    IERC20(want).safeApprove(poolPath[0], uint256(-1));

    IERC20(nativ).safeApprove(PancakeRouter, 0);
    IERC20(nativ).safeApprove(PancakeRouter, uint256(-1));
    }

    function _giveAllowancesCoin(address _coin) internal {
    IERC20(_coin).safeApprove(PancakeRouter, 0);
    IERC20(_coin).safeApprove(PancakeRouter, uint256(-1));
    }

    function deposit(address _coin, uint _amount) public {
    if (_coin == address(0)){
    depositCoin(_coin, _amount);
    }
    
    if (_coin == nativ){
    depositWbnb(_amount);
    }

    if (_coin == aBNBc){
    depositAwbnb(_amount);
    }

    if (_coin != address(0) && _coin != nativ && _coin != aBNBc){
    _giveAllowancesCoin(_coin);
    depositCoin(_coin, _amount);
    }
    }



    function withdraw(uint256 _shares, address _coin, address _user) public {
    if (_coin == aBNBc){
    withdrawAbnbc(_shares, _user);
    }
    if (_coin == nativ){
    withdrawNativ(_shares, _user);
    }
    if (_coin != nativ && _coin != aBNBc){

    withdrawCoin(_coin, _shares, _user);
    }
}
    //--------------

function depositCoin(address _coin, uint _amount) internal nonReentrant {
    
    IERC20(_coin).safeTransferFrom(msg.sender, address(this), _amount);
    pfad = [_coin, nativ];
    IRouter2(PancakeRouter).swapExactTokensForTokens(_amount, 0, pfad, address(this), now);

    uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
    IWombatRouter(wombatRouter).swapExactTokensForTokens(tokenPath, poolPath, wbnbBal, 0, address(this), now);

    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IDynamicPool(poolPath[0]).deposit(aBNBc, awbnbBal, 0, address(this), now, false);

    uint256 wantBal = IERC20(want).balanceOf(address(this));
    IVault(vault).deposit(wantBal , msg.sender);

    }

    function depositBNB() public payable {
    IWBNB(nativ).deposit{value : msg.value}();

    uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
    IWombatRouter(wombatRouter).swapExactTokensForTokens(tokenPath, poolPath, wbnbBal, 0, address(this), now);

    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IDynamicPool(poolPath[0]).deposit(aBNBc, awbnbBal, 0, address(this), now, false);

    uint256 wantBal = IERC20(want).balanceOf(address(this));
    IVault(vault).deposit(wantBal , msg.sender);

    }

function depositWbnb(uint _amount) internal nonReentrant {
    
    IERC20(nativ).safeTransferFrom(msg.sender, address(this), _amount);

    uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
    IWombatRouter(wombatRouter).swapExactTokensForTokens(tokenPath, poolPath, wbnbBal, 0, address(this), now);

    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IDynamicPool(poolPath[0]).deposit(aBNBc, awbnbBal, 0, address(this), now, false);

    uint256 wantBal = IERC20(want).balanceOf(address(this));
    IVault(vault).deposit(wantBal , msg.sender);

    }
      

function depositAwbnb(uint _amount) internal nonReentrant {

    IERC20(aBNBc).safeTransferFrom(msg.sender, address(this), _amount);
    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IDynamicPool(poolPath[0]).deposit(aBNBc, awbnbBal, 0, address(this), now, false);

    uint256 wantBal = IERC20(want).balanceOf(address(this));
    IVault(vault).deposit(wantBal , msg.sender);

}


//--------------

    function withdrawAbnbc(uint _shares, address _user) internal nonReentrant {
    IVault(vault).withdrawToZAP(_shares);

    uint256 amount = IERC20(want).balanceOf(address(this));
    IDynamicPool(poolPath[0]).withdraw(aBNBc, amount, 0, address(this), now);

    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IERC20(aBNBc).safeTransfer(_user, awbnbBal);
    }



    function withdrawCoin(address _coin, uint _shares, address _user) internal nonReentrant {
    IVault(vault).withdrawToZAP(_shares);

    _giveAllowancesCoin(_coin);
    uint256 amount = IERC20(want).balanceOf(address(this));
    IDynamicPool(poolPath[0]).withdraw(aBNBc, amount, 0, address(this), now);

    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IWombatRouter(wombatRouter).swapExactTokensForTokens(tokenPathBack, poolPath, awbnbBal, 0, address(this), now);

    uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
    pfad = [nativ, _coin];
    IRouter2(PancakeRouter).swapExactTokensForTokens(wbnbBal, 0, pfad, address(this), now);

    uint256 coinBal = IERC20(_coin).balanceOf(address(this));
    IERC20(_coin).safeTransfer( _user, coinBal);
    }





    function withdrawNativ(uint256 _shares, address _user) internal nonReentrant {
    IVault(vault).withdrawToZAP(_shares);
    uint256 amount = IERC20(want).balanceOf(address(this));
    IDynamicPool(poolPath[0]).withdraw(aBNBc, amount, 0, address(this), now);

    uint256 awbnbBal = IERC20(aBNBc).balanceOf(address(this));
    IWombatRouter(wombatRouter).swapExactTokensForTokens(tokenPathBack, poolPath, awbnbBal, 0, address(this), now);

    uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
    IWBNB(nativ).withdraw(wbnbBal);
    safeTransferBNB(address(_user), wbnbBal);
    }









    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    receive() external payable {}


    function setVault(address _vault) external {
        IERC20(want).safeApprove(_vault, 0);
        IERC20(want).safeApprove(_vault, uint256(-1));
        vault = _vault;
    }
}