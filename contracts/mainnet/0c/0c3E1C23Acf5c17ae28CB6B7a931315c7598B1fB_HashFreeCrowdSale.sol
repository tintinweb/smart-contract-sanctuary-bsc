/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// File: contracts/CrwodSale.sol


pragma solidity ^0.8.0;


//
//  888    888                   888      8888888888                                  .d8888b.                                      888  .d8888b.           888          
//  888    888                   888      888                                        d88P  Y88b                                     888 d88P  Y88b          888          
//  888    888                   888      888                                        888    888                                     888 Y88b.               888          
//  8888888888  8888b.  .d8888b  88888b.  8888888    888d888  .d88b.   .d88b.        888        888d888  .d88b.  888  888  888  .d88888  "Y888b.    8888b.  888  .d88b.  
//  888    888     "88b 88K      888 "88b 888        888P"   d8P  Y8b d8P  Y8b       888        888P"   d88""88b 888  888  888 d88" 888     "Y88b.     "88b 888 d8P  Y8b 
//  888    888 .d888888 "Y8888b. 888  888 888        888     88888888 88888888       888    888 888     888  888 888  888  888 888  888       "888 .d888888 888 88888888 
//  888    888 888  888      X88 888  888 888        888     Y8b.     Y8b.           Y88b  d88P 888     Y88..88P Y88b 888 d88P Y88b 888 Y88b  d88P 888  888 888 Y8b.     
//  888    888 "Y888888  88888P' 888  888 888        888      "Y8888   "Y8888         "Y8888P"  888      "Y88P"   "Y8888888P"   "Y88888  "Y8888P"  "Y888888 888  "Y8888  
//
// website: https://hashfree.xyz/                                                                                                                                                                     



interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function verifyCalldata(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }

    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }

    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    /**
     * @dev Calldata version of {processMultiProof}
     *
     * _Available since v4.7._
     */
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        // This function rebuild the root hash by traversing the tree up from the leaves. The root is rebuilt by
        // consuming and producing values on a queue. The queue starts with the `leaves` array, then goes onto the
        // `hashes` array. At the end of the process, the last hash in the `hashes` array should contain the root of
        // the merkle tree.
        uint256 leavesLen = leaves.length;
        uint256 totalHashes = proofFlags.length;

        // Check proof validity.
        require(leavesLen + proof.length - 1 == totalHashes, "MerkleProof: invalid multiproof");

        // The xxxPos values are "pointers" to the next value to consume in each array. All accesses are done using
        // `xxx[xxxPos++]`, which return the current value and increment the pointer, thus mimicking a queue's "pop".
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        // At each step, we compute the next hash using two values:
        // - a value from the "main queue". If not all leaves have been consumed, we get the next leaf, otherwise we
        //   get the next hash.
        // - depending on the flag, either another value for the "main queue" (merging branches) or an element from the
        //   `proof` array.
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i] ? leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++] : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }

        if (totalHashes > 0) {
            return hashes[totalHashes - 1];
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}


contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IHashFreeDao {
    function getRelations(address _address) external view returns(uint8 count, address[] memory);
    function payToken() external view returns(address);
    function setReferral(address origin, address referral) external;
}


interface IHashFreeNft {
    function safeMint(address to) external;
}

contract HashFreeCrowdSale is Ownable {
    using SafeERC20 for IERC20;

    struct Referral {
        address[] maxStakers;
        uint256 count;
        bool claimed;
    }
    mapping(address => Referral) public referrals;

    address public finance; // reposity for hashfree
    uint256 public amountRaised; // total amount from peledge
    uint256 public totalReFound; // total return to referral
    uint256 public deadline; // can only join crowdsale before
    uint256 public claimTime; // claim hashfree
    bytes32 public claimRoot; // upload by server node

    uint256 public constant BASE_STAKE_AMOUNT = 300 ether;
    uint256 public constant MAX_STAKE_AMOUNT = 500 ether;

    uint256 public REFUND_TASK = 10;
    uint256 public REWARD_FREE_COIN = 500;

    IERC20 public usdt;
    IERC20 public tokenReward; // user claim token
    IHashFreeNft public medal; // set minter to address(this)
    IHashFreeDao public freeDao;
    bool inPledge = false;
    modifier pledging() {
        require(!inPledge, "in pledging");
        inPledge = true;
        _;
        inPledge = false;
    }

    mapping(address => uint256) public pledgedAmount;
    mapping(address => bool) public claimed;

    event Pledge(
        address indexed caller,
        address indexed referral,
        uint256 amount,
        uint256 accrued
    );
    event MissionComplete(address receiver);
    event ClaimedSuccess(address receiver, uint256 amount);

    constructor(
        address _finance,
        address _freeDao,
        uint256 _deadline,
        uint256 _claimTime,
        address _medal
    ) {
        finance = _finance;
        freeDao = IHashFreeDao(_freeDao);
        deadline = _deadline;
        claimTime = deadline + _claimTime * 1 days;
        usdt = IERC20(freeDao.payToken());
        medal = IHashFreeNft(_medal);
    }

    function setTokenReward(IERC20 _tokenReward) external onlyOwner {
        tokenReward = _tokenReward;
    }

    function setFinance(address _finance) external onlyOwner {
        finance = _finance;
    }

    function setClaimtime(uint256 _claimtime) external onlyOwner {
        claimTime = _claimtime;
    }

    function setDeadLine(uint256 _deadline) external onlyOwner {
        deadline = _deadline;
    }

    function setTask(uint256 task) public onlyOwner {
        REFUND_TASK = task;
    }

    function setFreeDao(IHashFreeDao _dao) public onlyOwner {
        freeDao = _dao;
    }

    function setMedal(IHashFreeNft _medal) public onlyOwner {
        medal = _medal;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier beforeDeadline() {
        require(block.timestamp <= deadline, "crowd ended");
        _;
    }
    
    function getMaxStakers(address leader)
        public
        view
        returns (address[] memory maxStaker)
    {
        return referrals[leader].maxStakers;
    }

    function pledge(uint256 amount) external beforeDeadline pledging returns (bool) {
        Referral storage ref = referrals[msg.sender];
        require(amount >= 1 ether, "invalid amount");
        uint256 permit = ref.count >= REFUND_TASK
            ? MAX_STAKE_AMOUNT
            : BASE_STAKE_AMOUNT;
        pledgedAmount[msg.sender] += amount;
        require(pledgedAmount[msg.sender] <= permit, "over permit amount");

        usdt.safeTransferFrom(msg.sender, address(this), amount);
        amountRaised += amount;
        // check and get msg.sender award
        if (checkMission(msg.sender)) completeMission(msg.sender);
        // record referral
        (uint8 count, address[] memory relations) = freeDao.getRelations(
            msg.sender
        );
        address firstReferral = count > 0 ? relations[0] : address(0);
        emit Pledge(
            msg.sender,
            firstReferral,
            amount,
            pledgedAmount[msg.sender]
        );

        // caculte referral task and send reword to referral
        if (count > 0 && firstReferral != address(0)) {
            // only msg.sender peledge arrive maxamount
            // stake more than base_amount will not jion;keep join only once
            if (pledgedAmount[msg.sender] == BASE_STAKE_AMOUNT) {
                Referral storage firRef = referrals[firstReferral];
                firRef.count += 1;
                firRef.maxStakers.push(msg.sender);
            }
            if (checkMission(firstReferral)) completeMission(firstReferral);
        }
        return true;
    }

    function checkPledgePermit(address _target) public view returns(uint256 permit, uint256 left) {
        Referral memory ref = referrals[_target];
        permit = ref.count >= REFUND_TASK ? MAX_STAKE_AMOUNT : BASE_STAKE_AMOUNT;
        left = permit - pledgedAmount[_target];
    }

    function checkMission(address _target) public view returns(bool flag) {
            Referral memory ref = referrals[_target];
            // pledged baseamount 
            // already invite 10 people which had pledged baseamount
            // not yet claim
            uint256 staked = pledgedAmount[_target];
            if (
                staked >= BASE_STAKE_AMOUNT &&
                ref.count >= REFUND_TASK &&
                !ref.claimed
            ) {
                flag = true;
            }
    }

    function completeMission(address _winner) public {
        Referral storage ref = referrals[_winner];
        require(!ref.claimed, "already claimed");
        require(ref.count >= REFUND_TASK, "share to firends, hurry up");
        require(
            pledgedAmount[_winner] >= BASE_STAKE_AMOUNT,
            "not enough pledged"
        );
        ref.claimed = true;
        totalReFound += BASE_STAKE_AMOUNT;
        // refund usdt
        usdt.safeTransfer(_winner, BASE_STAKE_AMOUNT);
        // send nft
        medal.safeMint(_winner);
        // freecoin send
        IERC20(address(freeDao)).safeTransferFrom(
            finance,
            _winner,
            REWARD_FREE_COIN
        );
        emit MissionComplete(_winner);
    }

    // get claim hashfree though merkleproof once
    function claim(uint256 _amount, bytes32[] memory _proof) external {
        require(block.timestamp >= claimTime, "until claim time");
        require(
            checkoutEligibility(msg.sender, _amount, _proof),
            "varify failed!"
        );
        require(!claimed[msg.sender], "already claimed");
        claimed[msg.sender] = true;
        tokenReward.safeTransferFrom(finance, msg.sender, _amount);
        emit ClaimedSuccess(msg.sender, _amount);
    }
    
    function ownerWithdraw(address _token, address _to) public onlyOwner {
        if (_token == address(0x0)) {
            payable(_to).transfer(address(this).balance);
            return;
        }
        IERC20 token = IERC20(_token);
        token.transfer(_to, token.balanceOf(address(this)));
    }

    function checkoutEligibility(
        address account,
        uint256 amount,
        bytes32[] memory proof
    ) public view returns (bool) {
        return MerkleProof.verify(proof, claimRoot, _getKey(account, amount));
    }

    function setClaimRoot(bytes32 root_hash) public onlyOwner {
        claimRoot = root_hash;
    }

    function _getKey(address owner, uint256 amount)
        internal
        pure
        returns (bytes32)
    {
        bytes memory n = abi.encodePacked(_trs(owner), "-", _uint2str(amount));
        bytes32 q = keccak256(n);
        return q;
    }

    function _uint2str(uint256 _i)
        internal
        pure
        returns (bytes memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return bstr;
    }

    function _trs(address a) internal pure returns (string memory) {
        return _toString(abi.encodePacked(a));
    }

    function _toString(bytes memory data)
        internal
        pure
        returns (string memory)
    {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

}