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

import "./ReentrancyGuard.sol";
import "./IRouter2.sol";
import "./IWBNB.sol";
import "./Address.sol";
import "./SafeERC20.sol";
import "./ISale.sol";

pragma solidity 0.6.12;

contract ZAP is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;

    address public want = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public nativ = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public sale = 0xcD1e499a3EfBF47FC76153Bef9E2aB9E0938f948;

    address[] public path;

    address public pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    //---------------------------------------

    constructor() public {
        _giveAllowances();
    }

    function deposit(
        address _coin,
        uint256 _amount,
        address _sponsor
    ) public {
        if (_coin == want) {
            depositWant(_amount, _sponsor);
        }

        if (_coin == nativ) {
            depositNativ(_amount, _sponsor);
        }

        if (_coin != want && _coin != nativ) {
            _giveAllowancesCoin(_coin);
            depositCoin(_coin, _amount, _sponsor);
        }
    }

    //---------------------------------------

    function depositCoin(
        address _coin,
        uint256 _amount,
        address _sponsor
    ) internal nonReentrant {
        require(
            checkIfContract(msg.sender) == false,
            "SafeERC20: call from contract"
        );
        IERC20(_coin).safeTransferFrom(msg.sender, address(this), _amount);
        path = [_coin, nativ, want];
        IRouter2(pancakeRouter).swapExactTokensForTokens(
            _amount,
            0,
            path,
            address(this),
            now
        );
        ISale(sale).getTokens(msg.sender, _sponsor);
    }

    function depositBNB(address _sponsor) public payable nonReentrant {
        require(
            checkIfContract(msg.sender) == false,
            "SafeERC20: call from contract"
        );
        IWBNB(nativ).deposit{value: msg.value}();
        uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
        path = [nativ, want];
        IRouter2(pancakeRouter).swapExactTokensForTokens(
            wbnbBal,
            0,
            path,
            address(this),
            now
        );
        ISale(sale).getTokens(msg.sender, _sponsor);
    }

    function depositNativ(uint256 _amount, address _sponsor)
        internal
        nonReentrant
    {
        require(
            checkIfContract(msg.sender) == false,
            "SafeERC20: call from contract"
        );
        IERC20(nativ).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 wbnbBal = IERC20(nativ).balanceOf(address(this));
        path = [nativ, want];
        IRouter2(pancakeRouter).swapExactTokensForTokens(
            wbnbBal,
            0,
            path,
            address(this),
            now
        );
        ISale(sale).getTokens(msg.sender, _sponsor);
    }

    function depositWant(uint256 _amount, address _sponsor)
        internal
        nonReentrant
    {
        require(
            checkIfContract(msg.sender) == false,
            "SafeERC20: call from contract"
        );
        IERC20(want).safeTransferFrom(msg.sender, address(this), _amount);
        ISale(sale).getTokens(msg.sender, _sponsor);
    }

    //---------------------------------------

    receive() external payable {}

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    //---------------------------------------

    function _giveAllowances() internal {
        IERC20(want).safeApprove(sale, 0);
        IERC20(want).safeApprove(sale, uint256(-1));

        IERC20(nativ).safeApprove(pancakeRouter, 0);
        IERC20(nativ).safeApprove(pancakeRouter, uint256(-1));
    }

    function _giveAllowancesCoin(address _coin) internal {
        IERC20(_coin).safeApprove(pancakeRouter, 0);
        IERC20(_coin).safeApprove(pancakeRouter, uint256(-1));
    }

    function checkIfContract(address _address) public view returns (bool) {
        return _address.isContract();
    }
}