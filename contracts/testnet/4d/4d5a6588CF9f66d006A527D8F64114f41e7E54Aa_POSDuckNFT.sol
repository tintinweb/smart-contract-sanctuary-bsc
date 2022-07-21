/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

pragma solidity >=0.8.0;


interface IERC165 {
    
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    
    function balanceOf(address owner) external view returns (uint256 balance);

    
    function ownerOf(uint256 tokenId) external view returns (address owner);

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    
    function approve(address to, uint256 tokenId) external;

    
    function setApprovalForAll(address operator, bool _approved) external;

    
    function getApproved(uint256 tokenId) external view returns (address operator);

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {
    
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

interface IERC721Metadata is IERC721 {
    
    function name() external view returns (string memory);

    
    function symbol() external view returns (string memory);

    
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        
        

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    
    function toString(uint256 value) internal pure returns (string memory) {
        
        

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

abstract contract ERC165 is IERC165 {
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    
    string private _name;

    
    string private _symbol;

    
    mapping(uint256 => address) private _owners;

    
    mapping(address => uint256) private _balances;

    
    mapping(uint256 => address) private _tokenApprovals;

    
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

library Constants {

  

  uint256 internal constant PERCENT_PRECISION = 1e4;

  
  uint256 public constant MIN_PRICE = 0.01 ether;
  uint256 public constant FEE_PERCENT = 1000; 

  
  uint256 public constant MIN_INVESTMENT_TO_GET_BOOST = 0.1 ether;

  
  uint256 public constant STAKES_LIMIT = 100;

}

library Boosts {

  enum BoostType{ PROFIT, TIME, TEAM }

  struct Boost {
    BoostType boostType;
    uint256 boostTimePercent;
    uint256 boostProfitPercent;
  }

}

library Models {

  struct Buyer {
    uint256[] purchases;
    uint256 totalSpent;
    address referrer;
    address[] referrals;
    uint256 bonus;
    uint256[10] refs;
    uint256[10] refsNumber;
    uint8 refLevel;
    uint256 refTurnover;

    uint8 leaderLevel;
    bool mayBecomeLeader;
    bool isLeader;
  }

  struct StakeType {
    uint256 dailyPercent;
    uint256 term;
  }

  struct Stake {
    uint8 stakeTypeIdx;
    uint256 startTime;
    uint256 tokenId;
    mapping(uint8 => Boosts.Boost) boosts;
    uint8 boostsSize;
    uint256 lastWithdrawalTime;
    bool isExpired;
  }

}

library Events {
  event NFTBought(
    address indexed buyer,
    address indexed referrer,
    uint256 amount,
    uint256 indexed tokenId,
    uint256 timestamp
  );

  event NewBoost(
    address indexed buyer,
    Boosts.BoostType indexed boostType,
    uint256 indexed tokenId,
    string currency,
    uint256 amount,
    uint256 timePercent,
    uint256 profitPercent,
    uint256 timestamp
  );

  event Staked(
    address indexed investor,
    uint8 indexed stakeTypeIdx,
    uint256 indexed stakeIdx,
    uint256 tokenId,
    uint256 amount,
    uint256 timestamp
  );

  event Withdrawn(
    address indexed investor,
    uint8 indexed stakeTypeIdx,
    uint256 indexed stakeIdx,
    uint256 tokenId,
    uint256 reward,
    uint256 timestamp
  );

  event Unstaked(
    address indexed investor,
    uint8 indexed stakeTypeIdx,
    uint256 indexed stakeIdx,
    uint256 tokenId,
    uint256 timestamp
  );

  event ReferralBonusReceived(
    address indexed referrer,
    address indexed referral,
    uint256 indexed level,
    uint256 amount,
    uint256 timestamp
  );

  event BoostApplied(
    address indexed buyer,
    uint256 indexed stakeIdx,
    uint256 indexed boostTokenId,
    uint256 timestamp
  );

  event NewLeader(
    address indexed buyer,
    uint8 indexed leaderLevel,
    uint256 timestamp
  );

}

interface CommonInterface {

  

  function getPrice(uint256 tokenId) external view returns(uint256);

  

  function mintBoost(address receiver, Boosts.BoostType boostType, uint8 boostLevel) external;

  function mintLeaderBoost(address receiver, uint8 boostLevel) external;

  function getBoost(uint256 boostId) external view returns(Boosts.Boost memory boost);

  

  function ownerOf(uint256 tokenId) external view returns (address);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

}

contract ReferralProgram {

  address payable public immutable DEFAULT_REFERRER;
  address public immutable BOOST_NFT_CONTRACT_ADDRESS;

  uint256[] public REFERRAL_LEVELS_PERCENTS = [500, 700, 900, 1100, 1400, 1600, 1800, 2000];
  uint256[] public REFERRAL_LEVELS_MILESTONES = [0, 0.05 ether, 0.1 ether, 0.3 ether, 0.5 ether, 1 ether, 2 ether, 3 ether];
  uint256[] public LEADER_LEVELS_MILESTONES = [0, 0.01 ether, 0.05 ether, 0.1 ether, 0.3 ether, 0.5 ether, 1 ether, 2 ether, 3 ether, 4 ether, 5 ether];
  uint256[] public LEADER_LEVELS_USERS_MILESTONES = [0, 2, 4, 6, 9, 12, 15, 18, 21, 23, 28];
  uint8 constant public REFERRAL_DEPTH = 10;
  uint8 constant public REFERRAL_TURNOVER_DEPTH = 5;

  mapping (address => Models.Buyer) public buyers;

  mapping(address => mapping(uint8 => bool)) boostsReceived;

  constructor(address boostNFTContractAddress, address defaultReferrerAddress) {
    require(Address.isContract(boostNFTContractAddress), "01");

    BOOST_NFT_CONTRACT_ADDRESS = boostNFTContractAddress;
    DEFAULT_REFERRER = payable(defaultReferrerAddress);
  }

  function _distributeReferralReward(address buyerAddr_, address[] memory referrerAddrs_, uint256 amount_) internal {
    require(referrerAddrs_.length > 0 || buyers[buyerAddr_].referrer != address(0x0), "04");

    Models.Buyer storage buyer = buyers[buyerAddr_];

    bool isNewUser = false;
    if (buyer.referrer == address(0x0)) {
      isNewUser = true;
      if (referrerAddrs_[0] == address(0x0) || referrerAddrs_[0] == buyerAddr_) {
        buyer.referrer = DEFAULT_REFERRER;
      } else {
        buyer.referrer = referrerAddrs_[0];
        buyers[referrerAddrs_[0]].referrals.push(buyerAddr_);
      }

      if (referrerAddrs_.length > 1 && buyer.referrer != DEFAULT_REFERRER) { 
        for (uint8 i = 0; i < REFERRAL_DEPTH && i < referrerAddrs_.length - 1; i++) {
          if (buyers[referrerAddrs_[i]].referrer == address(0x0)) { 
            if (referrerAddrs_[i + 1] != address(0x0) && referrerAddrs_[i + 1] != referrerAddrs_[i]) {
              buyers[referrerAddrs_[i]].referrer = referrerAddrs_[i + 1];
              buyers[referrerAddrs_[i + 1]].referrals.push(referrerAddrs_[i]);

              for (uint8 j = 0; j < i; j++) {
                buyers[referrerAddrs_[i + 1]].refsNumber[j]++;
              }
            } else {
              buyers[referrerAddrs_[i]].referrer = DEFAULT_REFERRER;
              buyers[DEFAULT_REFERRER].referrals.push(referrerAddrs_[i]);

              for (uint8 j = 0; j < i; j++) {
                buyers[DEFAULT_REFERRER].refsNumber[j]++;
              }

              break;
            }
          }
        }
      }
    }

    bool[] memory distributedLevels = new bool[](REFERRAL_LEVELS_PERCENTS.length);

    address current = buyerAddr_;
    address upline = buyer.referrer;
    uint8 maxRefLevel = 0;
    for (uint8 i = 0; i < REFERRAL_DEPTH; i++) {
        uint256 refPercent = 0;
        if (i == 0) {
          refPercent = REFERRAL_LEVELS_PERCENTS[buyers[upline].refLevel];

          maxRefLevel = buyers[upline].refLevel;
          for (uint8 j = buyers[upline].refLevel; j >= 0; j--) {
            distributedLevels[j] = true;

            if (j == 0) {
              break;
            }
          }
        } else if (buyers[upline].refLevel > maxRefLevel && !distributedLevels[buyers[upline].refLevel]) {
          refPercent = REFERRAL_LEVELS_PERCENTS[buyers[upline].refLevel] - REFERRAL_LEVELS_PERCENTS[maxRefLevel];

          maxRefLevel = buyers[upline].refLevel;
          for (uint8 j = buyers[upline].refLevel; j >= 0; j--) {
            distributedLevels[j] = true;

            if (j == 0) {
              break;
            }
          }
        }

        uint256 amount = amount_ * refPercent / Constants.PERCENT_PRECISION;
        if (amount > 0) {
          if (buyers[upline].totalSpent > 0) {
            payable(upline).transfer(amount);
            buyers[upline].bonus+= amount;

            emit Events.ReferralBonusReceived(upline, buyerAddr_, i, amount, block.timestamp);
          } else {
            DEFAULT_REFERRER.transfer(amount);

            emit Events.ReferralBonusReceived(DEFAULT_REFERRER, buyerAddr_, i, amount, block.timestamp);
          }
        }

        buyers[upline].refs[i]++;
        if (isNewUser) {
          buyers[upline].refsNumber[i]++;
        }

        current = upline;
        upline = buyers[upline].referrer;
    }

    upline = buyerAddr_; 
    for (uint256 i = 0; i <= REFERRAL_TURNOVER_DEPTH; i++) {
        if (upline == address(0)) {
          break;
        }

        _updateReferralLevel(upline, amount_);
        _updateLeaderLevel(upline);

        upline = buyers[upline].referrer;
    }
  }

  function _updateReferralLevel(address buyerAddr_, uint256 amount_) private {
    buyers[buyerAddr_].refTurnover+= amount_;

    for (uint8 level = uint8(REFERRAL_LEVELS_MILESTONES.length - 1); level > 0; level--) {
      if (buyers[buyerAddr_].refTurnover >= REFERRAL_LEVELS_MILESTONES[level]) {
        buyers[buyerAddr_].refLevel = level;

        break;
      }
    }
  }

  function _updateLeaderLevel(address buyerAddr_) private {
    

    if (buyerAddr_ == DEFAULT_REFERRER) {
      return;
    }
    uint256 totalUsersAttracted = getTotalAttractedUsers(buyerAddr_);

    for (uint8 level = uint8(LEADER_LEVELS_MILESTONES.length - 1); level > buyers[buyerAddr_].leaderLevel; level--) {
      if (buyers[buyerAddr_].refTurnover >= LEADER_LEVELS_MILESTONES[level]
       && totalUsersAttracted >= LEADER_LEVELS_USERS_MILESTONES[level]
      ) {
        buyers[buyerAddr_].leaderLevel = level;
        buyers[buyerAddr_].mayBecomeLeader = true;

        address upline = buyers[buyerAddr_].referrer;
        for (uint8 i = 0; i < 100; i++) {
          if (upline == DEFAULT_REFERRER) {
            break;
          }

          if (buyers[upline].leaderLevel >= buyers[buyerAddr_].leaderLevel) {
            buyers[buyerAddr_].mayBecomeLeader = false;
            
            break;
          }

          upline = buyers[upline].referrer;
        }

        break;
      }
    }
  }

  function getTotalAttractedUsers(address leaderAddr) public view returns (uint256 usersCount) {
    for (uint8 i = 0; i < REFERRAL_TURNOVER_DEPTH; i++) {
      usersCount+= buyers[leaderAddr].refsNumber[i];
    }
  }

  function claimLeadership() external returns(bool) {
    
    require(buyers[msg.sender].mayBecomeLeader, "05");

    address upline = buyers[msg.sender].referrer;
    for (uint8 i = 0; i < 100; i++) {
      if (upline == DEFAULT_REFERRER) {
        break;
      }

      if (buyers[upline].leaderLevel >= buyers[msg.sender].leaderLevel) {
        buyers[msg.sender].mayBecomeLeader = false;
        
        

        break;
      }

      upline = buyers[upline].referrer;
    }

    if (buyers[msg.sender].mayBecomeLeader) {
      buyers[msg.sender].mayBecomeLeader = false;
      buyers[msg.sender].isLeader = true;
      claimBoost();

      emit Events.NewLeader(msg.sender, buyers[msg.sender].leaderLevel, block.timestamp);

      return true;
    }

    return false;
  }

  function claimBoost() public {
    
    require(buyers[msg.sender].totalSpent >= Constants.MIN_INVESTMENT_TO_GET_BOOST, "06");

    if (buyers[msg.sender].isLeader) { 
      if (!boostsReceived[msg.sender][buyers[msg.sender].leaderLevel]) {
        CommonInterface(BOOST_NFT_CONTRACT_ADDRESS)
          .mintLeaderBoost(msg.sender, buyers[msg.sender].leaderLevel - 1);

        boostsReceived[msg.sender][buyers[msg.sender].leaderLevel] = true;
      } else {
        revert("07");
      }
    } else { 
      address leader = findLeader(msg.sender);

      if (leader != DEFAULT_REFERRER) {
        if (!boostsReceived[msg.sender][buyers[leader].leaderLevel]) {
          CommonInterface(BOOST_NFT_CONTRACT_ADDRESS)
            .mintLeaderBoost(msg.sender, buyers[leader].leaderLevel - 1);

          boostsReceived[msg.sender][buyers[leader].leaderLevel] = true;
        } else {
          revert("07");
        }
      }
    }
  }

  function findLeader(address attractedAddr) public view returns(address) {
    address upline = buyers[attractedAddr].referrer;
    for (uint8 i = 0; i < 100; i++) {
      if (buyers[upline].isLeader || upline == DEFAULT_REFERRER) {
        break;
      }

      upline = buyers[upline].referrer;
    }

    return upline;
  }

  function getBuyerReferralsStats(address buyerAddr) external view
    returns (address, uint256, uint256[REFERRAL_DEPTH] memory, uint256[REFERRAL_DEPTH] memory, uint256, uint256)
  {
    Models.Buyer memory buyer = buyers[buyerAddr];

    return (
      buyer.referrer,
      buyer.bonus,
      buyer.refs,
      buyer.refsNumber,
      buyer.refLevel,
      buyer.refTurnover
    );
  }

  function referrals(address buyerAddr) external view returns(address[] memory) {
    return buyers[buyerAddr].referrals;
  }

}

contract POSDuckNFT is ReferralProgram, ERC721 {

  address public immutable owner;
  address payable public immutable FEE_RECEIVER;

  string private baseURI;
  address public mainContractAddress;

  
  uint256 public totalSpent;
  uint256 public nftOwnersCount;
  mapping(uint256 => uint256) private prices;

  constructor(
    string memory name_,
    string memory symbol_,
    string memory uri_,
    address boostNFTContractAddress,
    address defaultReferrerAddress,
    address feeReceiverAddress
  ) ERC721(name_, symbol_) ReferralProgram(boostNFTContractAddress, defaultReferrerAddress) {
    baseURI = uri_;

    owner = _msgSender();

    FEE_RECEIVER = payable(feeReceiverAddress);
  }

  receive() external payable {
    
    (bool sent, ) = mainContractAddress.call{value: msg.value}("");
    require(sent, "03");
  }

  function setMainContractAddress(address contractAddress) external {
    require(owner == _msgSender(), "00");
    require(Address.isContract(contractAddress), "01");
    require(mainContractAddress == address(0x0), "13");

    mainContractAddress = contractAddress;
  }

  function buy(address[] calldata referrerAddrs_) public payable {
    require(msg.value >= Constants.MIN_PRICE, "02");

    totalSpent+= msg.value;

    uint256 id = getID();
    buyers[msg.sender].purchases.push(id);
    buyers[msg.sender].totalSpent+= msg.value;
    prices[id] = msg.value;

    _distributeReferralReward(msg.sender, referrerAddrs_, msg.value);

    _mint(msg.sender, id);
    FEE_RECEIVER.transfer(msg.value * Constants.FEE_PERCENT / Constants.PERCENT_PRECISION);

    payable(mainContractAddress).transfer(address(this).balance);

    emit Events.NFTBought(
      msg.sender,
      referrerAddrs_.length > 0 ? referrerAddrs_[0] : address(0x0),
      msg.value,
      id,
      block.timestamp
    );
  }

  function changeBaseURI(string calldata newURI) external {
    require(owner == _msgSender(), "00");

    baseURI = newURI;
  }

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  

  

  function getPrice(uint256 tokenId) external view returns(uint256) {
    return prices[tokenId];
  }

  function buy() external payable {
    payable(msg.sender).transfer(msg.value);
  }

  function getID() private view returns(uint256) {
    uint256 id = block.timestamp;
    while (_exists(id)) { 
      id++;
    }

    return id;
  }

}