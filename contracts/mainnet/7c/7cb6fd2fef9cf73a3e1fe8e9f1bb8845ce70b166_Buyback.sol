/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

pragma solidity >=0.4.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.6.0;

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}


pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

interface ICloudEco{
    struct P2PQueue {
        address buyer;           // Address buyer
        address seller;          // Address seller
        uint256 amountXOS;
        uint256 amountUSDT;
        uint256 price;
        uint256 createDate;
        address referral;
    }
    function getAllQueueSellback() external view returns (P2PQueue[] memory);
}

contract Buyback{
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

     struct P2PQueue {
        address buyer;           // Address buyer
        address seller;          // Address seller
        uint256 amountXOS;
        uint256 amountUSDT;
        uint256 price;
        uint256 createDate;
        address referral;
    }

    ICloudEco cloudEco = ICloudEco(0xA258Ce5584909C9F510a09Dd9748767359D8269d);
    IBEP20 public rewardToken;
    IBEP20 public usdtToken;
    P2PQueue[] public queuebuyback;

    constructor(IBEP20 _usdtToken,IBEP20 _rewardToken) public{
        rewardToken = _rewardToken;
        usdtToken = _usdtToken;
    }

    function importBuyback() public{
        ICloudEco.P2PQueue[] memory oldQueue = cloudEco.getAllQueueSellback();
        for(uint i=0;i<oldQueue.length;i++){
            ICloudEco.P2PQueue memory old = oldQueue[i];
            if(old.seller != address(0) && old.amountXOS!=0){
                P2PQueue memory que;
                que.buyer = old.buyer;
                que.seller=old.seller; 
                que.amountXOS=old.amountXOS;
                que.amountUSDT=old.amountUSDT;
                que.price=old.price;
                que.createDate=old.createDate;
                que.referral=old.referral;
                queuebuyback.push(que);
            } 
        }
    }

    function savetrans(P2PQueue storage p2p) internal{
        //transfer busd to smart contract
        //uint256 amount = p2p.amountSwapToken/10000000000;
        usdtToken.safeTransferFrom(address(msg.sender),address(this), p2p.amountUSDT);
        //transfer busd to seller
        usdtToken.safeTransfer(address(p2p.seller), p2p.amountUSDT);
        //transfer xos to buyer
        rewardToken.safeTransfer(address(msg.sender), p2p.amountXOS);
    }


    function updateBuyback(uint256 totalXOSParam) public {
        P2PQueue[] storage p2pArray = queuebuyback;
        uint256 transXOS = totalXOSParam; 
        for(uint i=0;i<p2pArray.length;i++){
            P2PQueue storage p2p = queuebuyback[i];
            p2p.buyer = msg.sender;
            if(p2p.amountXOS<=transXOS && transXOS>0){
                transXOS = transXOS - p2p.amountXOS;
                savetrans(p2p);
                delete queuebuyback[i];
            }else{
                break;
            }
        }

        //reset queue
        resetQueue(queuebuyback);
    }

    function resetQueue(P2PQueue[] memory queue) internal{
        uint gap = 0;
        //define gap
        for (uint i = 0; i < queue.length-1; i++) {
            if(queue[gap].seller == address(0)){
                gap++;
                continue;
            }else{
                break;
            }
        }
        if(gap>0){
            for (uint i = 0; i < queue.length - gap; i++) {
                queue[i] = queue[i + gap];
            }
            for(uint i=0;i<gap;i++){
                delete queue[queue.length-(gap-i)];
            }
            
        }
    }

}