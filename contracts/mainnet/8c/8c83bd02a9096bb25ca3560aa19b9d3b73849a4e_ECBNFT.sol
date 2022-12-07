// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./SafeOwnable.sol";
import "./ERC721.sol";
import "./SmartDisPatchInitializable.sol";

contract ECBNFT is ERC721, SafeOwnable
{
    SmartDisPatchInitializable public dispatchHandle;

    mapping(address => bool) public isMinner;
    mapping(address => bool) public isExcludedDividend;

    event Mint(address account, uint256 tokenId);
    event NewMinner(address account);
    event DelMinner(address account);
    event SetExcludedDividend(address account);
    event DelExcludedDividend(address account);

    constructor() public ERC721("ECB token", "ECBT") {
        address mainAdds = 0x91AEF474eCC98638D021f1541c9E9c1177144703;
        isExcludedDividend[mainAdds] = true;
        isExcludedDividend[address(0)] = true;
        isExcludedDividend[address(this)] = true;
        isMinner[mainAdds] = true;
        isMinner[msg.sender] = true;
        for (uint256 i = 0; i != 100; i++) {
            mint(mainAdds);
        }
    }

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

    function setDispatchHandle(address _handle) external onlyOwner {
        dispatchHandle = SmartDisPatchInitializable(_handle);
    }

    function setExcludedDividend(address _account) external onlyOwner {
        require(
            _account != address(0),
            "ECB: account is zero address"
        );
        isExcludedDividend[_account] = true;
        emit SetExcludedDividend(_account);
    }

    function delExcludedDividend(address _account) external onlyOwner {
        require(
            _account != address(0),
            "ECB: account is zero address"
        );
        isExcludedDividend[_account] = false;
        emit DelExcludedDividend(_account);
    }

    function addMinner(address _minner) external onlyOwner {
        require(
            _minner != address(0),
            "ECB: minner is zero address"
        );
        isMinner[_minner] = true;
        emit NewMinner(_minner);
    }

    function delMinner(address _minner) external onlyOwner {
        require(
            _minner != address(0),
            "ECB: minner is zero address"
        );
        isMinner[_minner] = false;
        emit DelMinner(_minner);
    }

    function mint(address _recipient) public onlyMinner {
        require(
            _recipient != address(0),
            "ECB: recipient is zero address"
        );
        uint256 _tokenId = totalSupply() + 1;
        _mint(_recipient, _tokenId);
        emit Mint(_recipient, _tokenId);
    }

    function batchMint(address[] memory _recipients) external onlyMinner {
        for (uint256 i = 0; i != _recipients.length; i++) {
            mint(_recipients[i]);
        }
    }

    function setBaseURI(string memory baseUri) external onlyOwner {
        _setBaseURI(baseUri);
    }

    function claim(address token, address account) external {
        dispatchHandle.autoClaim(token, account);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (address(dispatchHandle) != address(0)) {
            if (from != address(0) && !isExcludedDividend[from]) {
                dispatchHandle.withdraw(from, 1);
            }
            if (!isExcludedDividend[to]) {
                dispatchHandle.stake(to, 1);
            }
        }
    }

    modifier onlyMinner() {
        require(
            isMinner[msg.sender],
            "ECB: caller is not the minner"
        );
        _;
    }
}