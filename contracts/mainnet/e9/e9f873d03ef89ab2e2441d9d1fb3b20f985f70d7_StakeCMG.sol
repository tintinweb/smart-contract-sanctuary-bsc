/**
 *Submitted for verification at BscScan.com on 2022-03-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IERC721  {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

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

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
contract StakeCMG 
{
  enum rango { copper, platium, gold, diamond}  
  using SafeMath for uint256;
  IERC20 public token_BUSD;
	address erctoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 
  address _admin = 0x9cCA2B481a0D9fae739C443f79E3095C9b232EA5;

    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public deposited_tokens;
    mapping(address => bool) public has_deposited;
    IERC721 public my_token;

    uint public Cooper_REWARD_PER_BLOCK = 0.1 ether;
    uint public platium_REWARD_PER_BLOCK = 0.2 ether;
    uint public gold_REWARD_PER_BLOCK = 0.3 ether;
    uint public diamond_REWARD_PER_BLOCK = 0.4 ether;

    constructor(){
        my_token = IERC721(0xEfca24b76aBbd794112b02B7293b59f7Ca3A23F5);
        
    }

    function deposit(uint256 tokenId, rango _rango) external
    {
        require (msg.sender == my_token.ownerOf(tokenId), 'Sender must be owner');
        require (!has_deposited[msg.sender], 'Sender already deposited');
        if(checkpoints[msg.sender] == 0){
            checkpoints[msg.sender] = block.number;
        }
        collect(msg.sender, _rango);
        my_token.transferFrom(msg.sender, address(this), tokenId);
        deposited_tokens[msg.sender] = tokenId;
        has_deposited[msg.sender] = true;
   }

    function withdraw(rango _rango) external
    {
        require(has_deposited[msg.sender], 'No tokens to withdarw');
        collect(msg.sender, _rango);
        my_token.transferFrom(address(this), msg.sender, deposited_tokens[msg.sender]);
        has_deposited[msg.sender] = false;
    }

    function collect(address beneficiary, rango _rango) public
    {
        uint256 reward = calculateReward(beneficiary, _rango);
        checkpoints[beneficiary] = block.number;      
        //_mint(msg.sender, reward);
        token_BUSD.transfer(msg.sender, reward);

    }

    function calculateReward(address beneficiary, rango _rango) public view returns(uint256)
    {
        if(!has_deposited[msg.sender])
        {
            return 0;
        }
        if(_rango == rango.copper){
        uint256 checkpoint = checkpoints[beneficiary];
          return Cooper_REWARD_PER_BLOCK * (block.number-checkpoint);
        }
       
    }
}