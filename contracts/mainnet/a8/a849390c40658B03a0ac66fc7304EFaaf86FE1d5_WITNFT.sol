// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeOwnable.sol";
import "./ERC721.sol";
import "./SmartDisPatchInitializable.sol";

contract WITNFT is
    ERC721("Witness&Bayc", "Witness&Bayc"),
    SafeOwnable
{
    SmartDisPatchInitializable public dispatchHandle;
    
    mapping(address => bool) public isMinner;
    mapping(uint256=>uint256)public token_nft;
    mapping(uint256=>uint256)public level_amount;
    string level1_url;
    string level2_url;
    string level3_url;
    event Mint(address account, uint256 tokenId);
    event NewMinner(address account);
    event DelMinner(address account);
    
    function createDispatchHandle(address _rewardToken) external onlyOwner {
        bytes memory bytecode = type(SmartDisPatchInitializable).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(address(this)));
        address poolAddress;
        assembly {
            poolAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        address[] memory adds = new address[](1);
        adds[0] = _rewardToken;
        SmartDisPatchInitializable(poolAddress).initialize(adds, msg.sender);

        dispatchHandle = SmartDisPatchInitializable(poolAddress);
    }
    function addlevel(uint256 _level,uint256 _amount)external onlyOwner{
        require(_level != 0 && _amount != 0);
        level_amount[_level] = _amount;
    }
    function setDispatchHandle(address _handle) external onlyOwner {
        dispatchHandle = SmartDisPatchInitializable(_handle);
    }
    function setLevelUrl(string memory _levelurl1,string memory _levelurl2,string memory _levelurl3)external onlyOwner{
        level1_url = _levelurl1;
        level2_url = _levelurl2;
        level3_url = _levelurl3;
    
    }
    function addMinner(address _minner) external onlyOwner {
        require(
            _minner != address(0),
            "BridgeCoinClub: minner is zero address"
        );
        isMinner[_minner] = true;
        emit NewMinner(_minner);
    }

    function delMinner(address _minner) external onlyOwner {
        require(
            _minner != address(0),
            "BridgeCoinClub: minner is zero address"
        );
        isMinner[_minner] = false;
        emit DelMinner(_minner);
    }

    function mint(address _recipient,uint256 level) public onlyMinner{
        require(
            _recipient != address(0),
            "BridgeCoinClub: recipient is zero address"
        );
        uint256 _tokenId = totalSupply() + 1;
        token_nft[_tokenId] = level;
        _mint(_recipient, _tokenId);
        emit Mint(_recipient, _tokenId);
            string memory url;

        if(level == 1){
            url = level1_url;
        }else if(level == 2){
            url = level2_url;
        }else if(level == 3){
            url = level3_url;
        }
        setTokenURI(_tokenId,url);
    }
   function setTokenURI(uint256 _tokenId,string memory _url)public onlyMinner{
        _setTokenURI(_tokenId,_url);
   }
    // function batchMint(address[] memory _recipients) external onlyMinner {
    //     for (uint256 i = 0; i != _recipients.length; i++) {
    //         mint(_recipients[i]);
    //     }
    // }

    function setBaseURI(string memory baseUri) external onlyOwner {
        _setBaseURI(baseUri);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (address(dispatchHandle) != address(0)) {
            
            if (from != address(0)) {
                dispatchHandle.withdraw(from, level_amount[token_nft[tokenId]]);
            }
            dispatchHandle.stake(to, level_amount[token_nft[tokenId]]);
        }
    }

    modifier onlyMinner() {
        require(
            isMinner[msg.sender],
            "BridgeCoinClub: caller is not the minner"
        );
        _;
    }
}