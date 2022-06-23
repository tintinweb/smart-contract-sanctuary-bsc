/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

     function name() external view returns (string memory);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IRewards {
    function claim(address _to, IERC20[] memory _rewardTokens) external;
}

contract OldRewards is ReentrancyGuard {
    address Reflecto = 0xEA3C823176D2F6feDC682d3cd9C30115448767b3;
    address OldContract = 0x871d5a028f2b26EF8051714A7dE167c42bc2a0b2;
    address RTO = 0x5A341DCF49e161CC73591f02e5f8CDE8A29733fb;

    function claim() external nonReentrant {
        address holder = msg.sender;

        uint256 balanceBeforeClaim = IERC20(Reflecto).balanceOf(holder);

        IERC20[] memory tokens;
        tokens[0] = IERC20(Reflecto);

        IRewards(OldContract).claim(holder, tokens);

        uint256 balanceAfterClaim = IERC20(Reflecto).balanceOf(holder);

        uint256 amountToSend = balanceAfterClaim - balanceBeforeClaim;

        if(amountToSend > 0) {
            IERC20(RTO).approve(
            address(this),
            amountToSend
            );
            IERC20(RTO).transferFrom(
                address(this),
                holder,
                amountToSend
            );
        }

    }
}