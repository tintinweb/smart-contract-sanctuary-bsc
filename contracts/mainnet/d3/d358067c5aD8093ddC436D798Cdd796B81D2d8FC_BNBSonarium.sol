/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
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


            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.4;

interface IPoseidonHasher {
    function poseidon(uint256[2] calldata inputs) external pure returns (uint256);
}

contract MerkleTreeHistory {

    uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint32 public constant ROOT_HISTORY_SIZE = 30;

    IPoseidonHasher public immutable hasher;

    uint32 public levels;
    uint32 public immutable maxSize;

    uint32 public index = 0;
    mapping(uint32 => uint256) public levelHashes;
    mapping(uint256 => uint256) public roots;
    uint256[] public leaves;

    constructor(uint32 _merkleTreeHeight, address _hasher) {
        require(_merkleTreeHeight > 0, "_levels should be greater than 0");
        require(_merkleTreeHeight <= 10, "_levels should not be greater than 10");
        levels = _merkleTreeHeight;
        hasher = IPoseidonHasher(_hasher);
        maxSize = uint32(2) ** levels;

        for (uint32 i = 0; i < _merkleTreeHeight; i++) {
            levelHashes[i] = zeros(i);
        }
    }

    function _insert(uint256 leaf) internal returns (uint32) {
        require(index != maxSize, "Merkle tree is full");
        require(leaf < FIELD_SIZE, "Leaf has to be within field size");

        leaves.push(leaf);

        uint32 currentIndex = index;
        uint256 currentLevelHash = leaf;
        uint256 left;
        uint256 right;

        for (uint32 i = 0; i < levels; i++) {
            if (currentIndex % 2 == 0) {
                left = currentLevelHash;
                right = zeros(i);
                levelHashes[i] = currentLevelHash;
            } else {
                left = levelHashes[i];
                right = currentLevelHash;
            }

            currentLevelHash = hasher.poseidon([left, right]);
            currentIndex /= 2;
        }

        roots[index % ROOT_HISTORY_SIZE] = currentLevelHash;

        index++;
        return index - 1;
    }

    function isKnownRoot(uint256 root) public view returns (bool) {
        if (root == 0) {
            return false;
        }

        uint32 currentIndex = index % ROOT_HISTORY_SIZE;
        uint32 i = currentIndex;
        do {
            if (roots[i] == root) {
                return true;
            }

            if (i == 0) {
                i = ROOT_HISTORY_SIZE;
            }
            i--;
        }
        while (i != currentIndex);

        return false;
    }

    function getLeavesLength() public view returns(uint256) {
        return leaves.length;
    }

    // poseidon(keccak256("easy-links") % FIELD_SIZE)
    function zeros(uint256 i) public pure returns (uint256) {
        if (i == 0) return 0x1b47eebd31a8cdbc109d42a60ae2f77d3916fdf63e1d6d3c9614c84c66587616;
        else if (i == 1) return 0x0998c45a8df60690d2142a1e29541e4c5203c5f0039e1f736a48a4ea3939996c;
        else if (i == 2) return 0x1b8525aeb12de720fbc32b7a5b505efc1bd4396e223644aed9d48c4ecc5a6451;
        else if (i == 3) return 0x1937e198ced295751ebf9996ad4429473bb657521a76f372ab62eab9dd09f729;
        else if (i == 4) return 0x043fae75b0a1c6cfe6bbd4a260fc421f26cd352974d31d3627896a677f3931a3;
        else if (i == 5) return 0x7c68bad132df37627c5fa5e1c06601d5af97124b0bd19f6e29593e1814ae51;
        else if (i == 6) return 0x2aca3ddb1f0c22cd53383b85231c1a10634f160ce945c639b2b799ed8b37f5ae;
        else if (i == 7) return 0x037ca32d66c15af3f7cb3cbc7d5b0fad9104582d24416fdd85c50586d3079a0e;
        else if (i == 8) return 0x1c9e22b869e38db54e772baa9a4765b9ccb1ea458ea4a50c3ce9ce5152a95581;
        else if (i == 9) return 0x283f3963c14e4a1873557637cf74773b5de1d3dcafa8c2c82f18720fabd5e0f9;
        else revert("Index out of bounds");
    }
}


    
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.4;

////import "./MerkleTreeHistory.sol";
////import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IVerifier {
    function verifyProof(
      uint256[2] calldata a,
      uint256[2][2] calldata b,
      uint256[2] calldata c,
      uint256[2] memory _input
    ) 
    external returns (bool);
}

abstract contract Sonarium is MerkleTreeHistory, ReentrancyGuard {
    IVerifier public verifier;
    uint256 public denomination;
    address public operator;
    uint256 public commission;
    address owner;

    mapping(uint256 => bool) public nullifierHashes;
    mapping(uint256 => bool) public commitments;

    event Deposit(
        uint256 indexed commitment,
        uint32 leafIndex,
        uint256 timestamp
    );
    // event Withdrawal(address to, uint256 nullifierHash);
    event Withdrawal(
        address to,
        uint256 nullifierHash
    );

    /**
        @dev Breakdown of the constructor
        @param _verifier the address of SNARK verifier for this contract
        @param _hasher the address of Poseidon hash contract
        @param _denomination transfer amount for each deposit
        @param _merkleTreeHeight the height of deposits' Merkle Tree
  */

    constructor(
        IVerifier _verifier,
        address _hasher,
        uint256 _denomination,
        uint32 _merkleTreeHeight,
        address _operator,
        uint256 _commission
    ) MerkleTreeHistory(_merkleTreeHeight, _hasher) {
        require(
            _denomination > 0,
            "Sonarium: Denomination should be greater than 0"
        );
        owner = msg.sender;
        verifier = _verifier;
        denomination = _denomination + _commission;
        operator = _operator;
        commission = _commission;
    }

    /**
    @dev Deposit funds into the contract. The caller must send (for BNB) or approve (for ERC20) value equal to or `denomination` of this instance.
    @param _commitment the note commitment, which is a Poseidon hash of(nullifier + secret)
  */

    function deposit(uint256 _commitment) external payable {
        require(
            !commitments[_commitment],
            "Sonarium: The commitment has been submitted"
        );

        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;
        _processDeposit();

        emit Deposit(_commitment, insertedIndex, block.timestamp);
    }

    function _processDeposit() internal virtual;

    function setOperator(address newOperator) external {
        require(
            msg.sender == owner,
            "This can only be called by the contract owner!"
        );

        operator = newOperator;
    }

    function setCommission(uint256 newCommission) external {
        require(
            msg.sender == owner,
            "This can only be called by the contract owner!"
        );
        uint256 oldDenomination = denomination - commission;
        commission = newCommission;
        denomination = oldDenomination + newCommission;
    }

    /** @dev this function is defined in a child contract */

    /**
    @dev Withdraw a deposit from the contract.
  **/
    function withdraw(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256 _root,
        uint256 _nullifierHash,
        address payable _recipient
    ) external payable nonReentrant {
        require(msg.sender == operator, "Sonarium: This can only be called by the contract operator!");
        require(
            !nullifierHashes[_nullifierHash],
            "Sonarium: The note has already been spent"
        );
        require(isKnownRoot(_root), "Sonarium: merkle root does not exist");

        require(
            verifier.verifyProof(
                a,
                b,
                c,
                [
                    uint256(_root),
                    uint256(_nullifierHash)
                ]
            ),
            "Sonarium: Invalid withdraw proof"
        );

        nullifierHashes[_nullifierHash] = true;
        _processWithdraw(_recipient);
        emit Withdrawal(_recipient, _nullifierHash);
    }

    /** @dev this function is defined in a child contract */
function _processWithdraw(
        address payable _recipient
    ) internal virtual;

    /** @dev whether a note is already spent */
    function isSpent(uint256 _nullifierHash) public view returns (bool) {
        return nullifierHashes[_nullifierHash];
    }

    /** @dev whether an array of notes is already spent */
    function isSpentArray(uint256[] calldata _nullifierHashes)
        external
        view
        returns (bool[] memory spent)
    {
        spent = new bool[](_nullifierHashes.length);
        for (uint256 i = 0; i < _nullifierHashes.length; i++) {
            if (isSpent(_nullifierHashes[i])) {
                spent[i] = true;
            }
        }
    }
}


////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.4;
////import "./Sonarium.sol";

contract BNBSonarium is Sonarium {
    constructor(IVerifier _verifier, address _hasher, uint256 _denomination, uint32 _merkleTreeHeight, address _operator, uint256 _commission ) Sonarium(_verifier, _hasher, _denomination, _merkleTreeHeight, _operator, _commission) {}

    function _processDeposit() internal override {
        require(msg.value == denomination, "Sonarium: Please send `Denomination` BNB along with transaction");
    }

    // function _processWithdraw(address payable _recipient) internal override {
    //     require(msg.value == 0, "Sonarium: Message value is supposed to be zero for BNB");
    //             payable(_recipient).transfer(denomination - commission);
    //             payable(_operator).transfer( commission);

    //     (bool success, ) = _recipient.call{value: (denomination - commission)}("");
    //     (bool success2, ) = operator.call{value: commission }("");

    //     require(success, "Sonarium: payment to _recipient was not successful");
    //     require(success2, "Sonarium: payment to operator was not successful");


    // }

    function _processWithdraw(
        address payable _recipient
        ) internal override{
        // sanity checks
        require(
            msg.value == 0,
            "Message value is supposed to be zero for native asset instance"
        );
           require(msg.sender == operator, "Sonarium: This can only be called by the contract operator!");
      (bool success, ) = operator.call{value: commission }("");

            require(success, "payment to _relayer did not go thru");
        
        (bool success2, ) = _recipient.call{value: (denomination - commission)}("");
        require(success2, "payment to _recipient did not go thru");

      
    }
}