/**
 *Submitted for verification at BscScan.com on 2023-02-18
*/

/**
 *Submitted for verification at BscScan.com on 2023-02-17
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity 0.8.9;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

pragma solidity 0.8.9;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeERC20 {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(token.approve(spender, value));
    }
}

abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

    function processProof(bytes32[] memory proof, bytes32 leaf)
        internal
        pure
        returns (bytes32)
    {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }

    function _efficientHash(bytes32 a, bytes32 b)
        private
        pure
        returns (bytes32 value)
    {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}

contract SeedifyLaunchpad is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address[] private whitelist;
    uint256 public nftPrice;
    address public projectOwner;
    address public tokenAddress;
    bytes32 public rootHash;
    uint256 public totalSupply;
    uint256 public totalRaised;
    uint256 public nftPurchased;
    IERC20 public ERC20Interface;
    event Whitelisted(address indexed _address);
    event RemovedFromWhitelist(address indexed account);
    mapping(address => bool) public isBuy;

    constructor(
        uint256 _busdPrice,
        address _projectOwner,
        address _tokenAddress,
        uint256 _totalSupply
    ) {
        nftPrice = _busdPrice * 10**18;
        require(_projectOwner != address(0), "Zero project owner address");
        projectOwner = _projectOwner;
        require(_tokenAddress != address(0), "Zero token address");
        tokenAddress = _tokenAddress;
        totalSupply = _totalSupply;
        ERC20Interface = IERC20(tokenAddress);
    }

    function updateNFTprice(uint256 _NFTPrice) public onlyOwner {
        require(_NFTPrice > 0, "Zero busdPrice");
        nftPrice = _NFTPrice * 10**18;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //add the address in Whitelist
    function addWhitelist(address[] memory _address) public onlyOwner {
        uint256 i;
        uint256 length = _address.length;
        for (i = 0; i < length; i++) {
            address _addressArr = _address[i];
            whitelist.push(_addressArr);
            emit Whitelisted(_addressArr);
        }
    }

    //remove the address in Whitelist
    function removeWhitelist(address[] memory _address) public onlyOwner {
        uint256 i;
        uint256 j;
        uint256 addressLength = _address.length;
        uint256 whitelistLength = whitelist.length;
        for (i = 0; i < addressLength; i++) {
            for (j = 0; j < whitelistLength; j++) {
                address _addressArr = _address[i];
                address _whitelistArr = whitelist[j];
                if (_whitelistArr == _addressArr) {
                    delete whitelist[j];
                    emit RemovedFromWhitelist(_addressArr);
                }
            }
        }
    }

    // check the address in whitelist
    function isWhitelisted(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelist.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelist[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    function updateHash(bytes32 _hash) public onlyOwner {        
        rootHash = _hash;
    }

    function buyTokens(uint256 amount, uint256 allocation)
        public
        whenNotPaused
    {
       // require(verify(sender, allocation, proof, rootHash), "User not authenticated");

        require((isBuy[msg.sender] == false), "You have already buy the item");
        require(amount == nftPrice, "amount is different");
        ERC20Interface.safeTransferFrom(msg.sender, projectOwner, amount);
        nftPurchased += allocation;
        isBuy[msg.sender] = true;
     //   totalRaised = totalRaised.add(amount);
       // return true;
    }

    function verify(
        address user,
        uint256 allocation,
        bytes32[] calldata proof,
        bytes32 _rootHash
    ) public pure returns (bool) {
        return (    
            MerkleProof.verify(
                proof,
                _rootHash,
               keccak256(abi.encodePacked(user, allocation))
            )
        );
    }
}