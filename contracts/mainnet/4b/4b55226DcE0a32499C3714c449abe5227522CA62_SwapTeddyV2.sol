/**
 *Submitted for verification at BscScan.com on 2022-08-13
*/

// SPDX-License-Identifier: GCT
pragma solidity ^0.8.1;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.8.1;
library Safe{
    function SafeCall(address target, bytes memory data) internal returns (bytes memory) {
         require(target.code.length > 0, "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value : 0}(data);
        return verifyCallResult(success, returndata, "Address: low-level call failed");
    }
    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
pragma solidity ^0.8.1;
contract SwapTeddyV2{
    using Safe for address;
    address public owner;
    address public teddyV1=address(0x10f6f2b97F3aB29583D9D38BaBF2994dF7220C21);
    address public teddyV2=address(0xDB79c12d1d0670988A39B0E48b96e955eF922d24);
    uint256 public maxAmount=500000000000*10**18;
    uint256 public startTime;
    uint256 public endTime;
    constructor(uint256 _startTime){
        owner=_msgSender();
        startTime=_startTime;
        endTime=_startTime+24*3600*17;//Ends after 17 days of redemption time
    }

    function _msgSender() internal view returns(address){
        return msg.sender;
    }

    modifier onlyOwner{
        require(_msgSender()==owner,"not is owner");
        _;
    }

//Burn the remainder to exchange for more Teddy V2
    function burnV2() public onlyOwner{
        IERC20 addr=IERC20(teddyV2);
        uint256 amount=addr.balanceOf(address(this));
        require(amount>0,"balance is 0");
        teddyV2.SafeCall(abi.encodeWithSelector(
            addr.burn.selector,
            amount
        ));
    }
    

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }  

    function swap(uint256 amount) public virtual{
        require(amount<=maxAmount,"amount more then the max amount ");
        require(startTime<=block.timestamp,"swap is not start");
        require(endTime>block.timestamp,"swap is end");
        require(amount>0,"swap amount must be more then 0");
        address from=_msgSender();
        teddyV1.SafeCall(
            abi.encodeWithSelector(
                IERC20(teddyV1).transferFrom.selector,
                from,address(this),
                amount
            )
        );
         teddyV2.SafeCall(
             abi.encodeWithSelector(
                 IERC20(teddyV2).transfer.selector,
                 from,
                 amount
            )
        );
    }
}