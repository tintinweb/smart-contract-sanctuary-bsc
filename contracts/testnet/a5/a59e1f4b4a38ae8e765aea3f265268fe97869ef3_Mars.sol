// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "Ownable.sol";
import "ERC721Enumerable.sol";
import "ReentrancyGuard.sol";
import "LBTOKEN.sol";
import "LH2TOKEN.sol";

contract Mars is ERC721Enumerable, ReentrancyGuard, Ownable {

    string public Mars_PROVENANCE = "Mars";
    string public baseTokenURI;

    uint256 public MAX_Mars = 30000;
    uint256 public namingMarsPrice = 3000 ether;
    uint256 public rewardPrice = 0.0023 ether;
	uint256 public mintLBTPrice = 100000 ether;
    uint256 public mintLH2Price = 1000 ether;


    address public daoAddress;
    address public teamAddress;
    address public nameAddress;
    uint256 public teamFee = 2;
    uint256 public daoFee = 3;
    uint256 public mintAmount = 1;

    bool public mintIsActive = true;

    mapping(uint256 => string) public nameMars;
    mapping(address => uint256) public balanceMars;

    LBTOKEN public lbToken;
    LH2TOKEN public LH2Token;
    IROCKET public rocketContract;

    event NameChanged(string name);

    constructor() ERC721("Mars", "Mars") {
    }

    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function setMaxMars(uint256 amount) public onlyOwner {
        MAX_Mars = amount;
    }

    function setRocketContract(address _rocket) external onlyOwner {
        rocketContract = IROCKET(_rocket);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
    }

    function setProvenanceHash(string memory provenanceHash) public onlyOwner {
        Mars_PROVENANCE = provenanceHash;
    }


    function setLBToken(address _lbt) external onlyOwner {
        lbToken = LBTOKEN(_lbt);
    }

    function setLH2Token(address _lh2) external onlyOwner {
        LH2Token = LH2TOKEN(_lh2);
    }

    function setDaoFee(uint256 _daoFee) external onlyOwner {
        daoFee = _daoFee;
    }

    function setTeamFee(uint256 _teamFee) external onlyOwner {
        teamFee = _teamFee;
    }

    function setMintAmount(uint256 _mintAmount) external onlyOwner {
        mintAmount = _mintAmount;
    }


    function setBalanceMars(address wallet, uint256 _newBalance) external onlyOwner {
        balanceMars[wallet] = _newBalance;
    }

    function setBurnRate(uint256 _namingPrice) external onlyOwner {
        namingMarsPrice = _namingPrice;
    }

    function setMintLBTPrice(uint256 _mintPrice) external onlyOwner {
        mintLBTPrice = _mintPrice;
    }
	
	function setMintLH2Price(uint256 _mintPrice) external onlyOwner {
        mintLH2Price = _mintPrice;
    }

    function setRewardPrice(uint256 _rewardPrice) external onlyOwner {
        rewardPrice = _rewardPrice;
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);

        payable(msg.sender).transfer(balance);
    }

  /**
    * @dev Allow contract owner to withdraw ERC-20 balance from contract
    * while still splitting royalty payments to all other team members.
    * in the event ERC-20 tokens are paid to the contract.
    * @param _tokenContract contract of ERC-20 token to withdraw
    * @param _amount balance to withdraw according to balanceOf of ERC-20 token
    */
  function withdrawAllERC20(address _tokenContract, uint256 _amount) public onlyOwner {
    require(_amount > 0);
    IERC20 tokenContract = IERC20(_tokenContract);
    require(tokenContract.balanceOf(address(this)) >= _amount, 'Contract does not own enough tokens');
    tokenContract.transfer(msg.sender, _amount );
  }

    function flipMint() public onlyOwner {
        mintIsActive = !mintIsActive;
    }

    function mintAdmin(uint256[] calldata tokenIds, address _to) public payable onlyOwner {
        require(totalSupply() < MAX_Mars, "Max supply reached");
        require(totalSupply() + tokenIds.length <= MAX_Mars, "Minting would exceed max supply of Mars");

        for(uint256 i = 0; i < tokenIds.length; i++) {
            require(tokenIds[i] < MAX_Mars, "Invalid token ID");
            require(!_exists(tokenIds[i]), "Tokens has already been minted");

            if (totalSupply() < MAX_Mars) {
                _safeMint(_to, tokenIds[i]);
                balanceMars[_to] += 1;
            }
        }
        //update reward on mint
        lbToken.updateRewardOnMint(_to, tokenIds.length);
    }

    function mint() public payable nonReentrant {
        require(mintIsActive, "Migration must be active in order to mint");
        require(totalSupply() <= MAX_Mars, "Max supply reached");
        require(totalSupply() + mintAmount <= MAX_Mars, "Minting would exceed max supply of Mars");
        require(lbToken.balanceOf(msg.sender) >=mintLBTPrice * mintAmount, "Balance insufficient");
		require(LH2Token.balanceOf(msg.sender) >=mintLH2Price * mintAmount, "Balance insufficient");
        require(balanceOf(msg.sender) + mintAmount<=mintAmount, "Wallet address is over the maximum allowed mints");
        require(rocketContract.balanceOf(msg.sender) > 0, "Not the owner of Rocket NFT");


        uint256 daoLBTAmount = mintLBTPrice * mintAmount* daoFee / 100;
        uint256 teamLBTAmount = mintLBTPrice * mintAmount* teamFee / 100;
        uint256 burnLBTAmount = mintLBTPrice * mintAmount* (100-daoFee-teamFee) / 100;

        lbToken.burnFrom(msg.sender, burnLBTAmount); 
        lbToken.transferFeeFrom(msg.sender,daoAddress,daoLBTAmount); 
        lbToken.transferFeeFrom(msg.sender,teamAddress,teamLBTAmount); 
		
		uint256 daoLH2Amount = mintLH2Price * mintAmount* daoFee / 100;
        uint256 teamLH2Amount = mintLH2Price * mintAmount* teamFee / 100;
        uint256 burnLH2Amount = mintLH2Price * mintAmount* (100-daoFee-teamFee) / 100;

        LH2Token.burnFrom(msg.sender, burnLH2Amount); 
        LH2Token.transferFeeFrom(msg.sender,daoAddress,daoLH2Amount); 
        LH2Token.transferFeeFrom(msg.sender,teamAddress,teamLH2Amount);

        for(uint256 i = 0; i < mintAmount; i++) {
            if (totalSupply() < MAX_Mars) {
                _safeMint(msg.sender,totalSupply()+1);
                balanceMars[msg.sender] += 1;
            }
        }
        //update reward on mint
        LH2Token.updateRewardOnMint(msg.sender, mintAmount);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override nonReentrant {
        LH2Token.updateReward(from, to, tokenId);
        balanceMars[from] -= 1;
        balanceMars[to] += 1;

        ERC721.transferFrom(from, to, tokenId);
    }

    function setDaoAddress(address _daoAddress) external onlyOwner {
        daoAddress = _daoAddress;
    }

    function setTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;
    }

    function setNameAddress(address _nameAddress) external onlyOwner {
        nameAddress = _nameAddress;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override nonReentrant {
        LH2Token.updateReward(from, to, tokenId);
        balanceMars[from] -= 1;
        balanceMars[to] += 1;

        ERC721.safeTransferFrom(from, to, tokenId, _data);
    }

    function getReward() external payable {
        require(msg.value == rewardPrice, "Value needs to be exactly the reward fee!");
        LH2Token.updateReward(msg.sender, address(0), 0);
        LH2Token.getReward(msg.sender);
    }

    function changeName(uint256 _tokenId, string memory _newName) public {
        require(ownerOf(_tokenId) == msg.sender);
        require(validateName(_newName) == true, "Invalid name");
        
        //can not set the same name
        for (uint256 i; i < totalSupply(); i++) {
            if (bytes(nameMars[i]).length != bytes(_newName).length) {
                continue;
        } else {
            require(keccak256(abi.encode(nameMars[i])) != keccak256(abi.encode(_newName)), "name is used");
        }
        }


        lbToken.transferFeeFrom(msg.sender,nameAddress,namingMarsPrice); 
        nameMars[_tokenId] = _newName;

        emit NameChanged(_newName);
    }

    function validateName(string memory str) internal pure returns (bool) {
        bytes memory b = bytes(str);

        if(b.length < 1) return false;
        if(b.length > 15) return false;
        if(b[0] == 0x20) return false; // Leading space
        if(b[b.length - 1] == 0x20) return false; // Trailing space

        bytes1 lastChar = b[0];


        for (uint256 i; i < b.length; i++) {
            bytes1 char = b[i];

            if (char == 0x20 && lastChar == 0x20) return false; // Cannot contain continous spaces

            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A)  //A-Z
            ) {
                return false;
            }

            lastChar = char;
        }

        return true;
    }
}