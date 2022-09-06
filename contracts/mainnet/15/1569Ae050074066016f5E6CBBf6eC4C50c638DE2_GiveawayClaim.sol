/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    function balanceOf(address account) external view returns (uint256);
    
    function decimals() external view returns (uint8);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract GiveawayClaim is Ownable {


    address public constant SKP = 0x1234AE511876FCAaCe685fcDC292d9589A88dC2b;

    address public projectToken;

    uint256 public minimumProjectTokensOwned;

    bytes32 public hashedPassphrase;

    uint256 public claimsLeft;

    uint256 public giveAwayClaim = 1_000 * 10**18;

    mapping ( address => bool ) public hasClaimed;
    address[] public claimers;

    function setClaimQuantity(uint256 newClaim) external onlyOwner {
        giveAwayClaim = newClaim;
    }

    function setNewProject(
        address projectToken_,
        uint256 minimumProjectTokenOwnedThreshold,
        bytes32 hashedPassphrase_
    ) external onlyOwner {

        uint len = claimers.length;
        if (len > 0) {
            for (uint i = 0; i < len;) {
            delete hasClaimed[claimers[i]];
            unchecked { ++i; }
            }
            delete claimers;
        }

        projectToken = projectToken_;
        minimumProjectTokensOwned = minimumProjectTokenOwnedThreshold;
        hashedPassphrase = hashedPassphrase_;
        claimsLeft = IERC20(SKP).balanceOf(address(this)) / giveAwayClaim;
    }

    function claim(string calldata passphrase) external {
        require(
            hasClaimed[msg.sender] == false,
            'Has Already Claimed'
        );
        require(
            hash(passphrase) == hashedPassphrase,
            'Incorrect Passphrase'
        );
        require(
            claimsLeft > 0,
            'Zero Claims Left'
        );
        require(
            IERC20(projectToken).balanceOf(msg.sender) >= minimumProjectTokensOwned,
            'Project Minimum Not Met'
        );

        hasClaimed[msg.sender] = true;
        claimers.push(msg.sender);
        claimsLeft--;

        IERC20(SKP).transfer(msg.sender, giveAwayClaim);
    }

    function hash(string calldata value) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(value));
    }

}