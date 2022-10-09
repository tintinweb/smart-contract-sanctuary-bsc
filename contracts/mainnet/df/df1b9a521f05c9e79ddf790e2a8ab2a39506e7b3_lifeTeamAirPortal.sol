/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);
}

contract lifeTeamAirPortal {
    address private _token;
    address private Foundation;
    uint256 private months = 1;
    uint256 private mnext = 0;

    constructor(
        address token_,
        address addf_,
        uint256 start_
    ) {
        _token = token_;
        Foundation = addf_;
        mnext = start_;
    }

    function AirPortal() external {
        require(mnext != 0 && mnext < block.timestamp, "error time");
        _AirPortal();
    }

    function _AirPortal() private {
        IERC20 tokenContract = IERC20(_token);
        uint8 decimal = tokenContract.decimals();
        if (months >= 42) {
            tokenContract.transfer(Foundation, 35726 * (10**decimal));
        } else {
            tokenContract.transfer(Foundation, 35714 * (10**decimal));
        }
        mnext = mnext + 30 days;
        months++;
    }

    function NextAirPortal() public view returns (uint256 nexttime) {
        return mnext;
    }
    
    function getToken() external view returns (address) {
        return _token;
    }
}