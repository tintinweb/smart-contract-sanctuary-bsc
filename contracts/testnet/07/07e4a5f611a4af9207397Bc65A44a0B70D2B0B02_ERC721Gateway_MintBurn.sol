/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Administrable {
    address public admin;
    address public pendingAdmin;
    event LogSetAdmin(address admin);
    event LogTransferAdmin(address oldadmin, address newadmin);
    event LogAcceptAdmin(address admin);

    function setAdmin(address admin_) internal {
        admin = admin_;
        emit LogSetAdmin(admin_);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        address oldAdmin = pendingAdmin;
        pendingAdmin = newAdmin;
        emit LogTransferAdmin(oldAdmin, newAdmin);
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
        emit LogAcceptAdmin(admin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }
}


// File contracts/interfaces/IAnycallV6Proxy.sol

pragma solidity ^0.8.1;
interface IAnycallV6Proxy {
    function anyCall(
        address _to,
        bytes calldata _data,
        address _fallback,
        uint256 _toChainID,
        uint256 _flags
    ) external payable;

    function executor() external view returns (address);
}


// File contracts/interfaces/IExecutor.sol

pragma solidity ^0.8.1;
interface IExecutor {
    function context() external returns (address from, uint256 fromChainID, uint256 nonce);
}


// File contracts/AnyCallApp.sol

pragma solidity ^0.8.1;



abstract contract AnyCallApp is Administrable {
    uint256 public flag; // 0: pay on dest chain, 2: pay on source chain
    address public immutable anyCallProxy;

    mapping(uint256 => address) internal peer;

    event SetPeers(uint256[] chainIDs, address[] peers);
    event SetAnyCallProxy(address proxy);

    modifier onlyExecutor() {
        require(msg.sender == IAnycallV6Proxy(anyCallProxy).executor());
        _;
    }

    constructor (address anyCallProxy_, uint256 flag_) {
        anyCallProxy = anyCallProxy_;
        flag = flag_;
    }

    function setPeers(uint256[] memory chainIDs, address[] memory  peers) public onlyAdmin {
        for (uint i = 0; i < chainIDs.length; i++) {
            peer[chainIDs[i]] = peers[i];
            emit SetPeers(chainIDs, peers);
        }
    }

    function getPeer(uint256 foreignChainID) external view returns (address) {
        return peer[foreignChainID];
    }

    /**
     * @dev Uncomment this function if the app owner wants full control of the contract.
     */
    //function setAnyCallProxy(address proxy) public onlyAdmin {
    //    anyCallProxy = proxy;
    //    emit SetAnyCallProxy(proxy);
    //}

    function _anyExecute(uint256 fromChainID, bytes calldata data) internal virtual returns (bool success, bytes memory result);

    function _anyCall(address _to, bytes memory _data, address _fallback, uint256 _toChainID) internal {
        if (flag == 2) {
            IAnycallV6Proxy(anyCallProxy).anyCall{value: msg.value}(_to, _data, _fallback, _toChainID, flag);
        } else {
            IAnycallV6Proxy(anyCallProxy).anyCall(_to, _data, _fallback, _toChainID, flag);
        }
    }

    function anyExecute(bytes calldata data) external onlyExecutor returns (bool success, bytes memory result) {
        (address callFrom, uint256 fromChainID,) = IExecutor(IAnycallV6Proxy(anyCallProxy).executor()).context();
        require(peer[fromChainID] == callFrom, "call not allowed");
        _anyExecute(fromChainID, data);
    }

}


// File contracts/interfaces/IERC721Gateway.sol

pragma solidity ^0.8.1;
interface IERC721Gateway {
    function token() external view returns (address);
    function Swapout_no_fallback(uint256 tokenId, address receiver, uint256 toChainID) external payable returns (uint256 swapoutSeq);
}


// File contracts/ERC721Gateway.sol

pragma solidity ^0.8.1;


abstract contract ERC721Gateway is IERC721Gateway, AnyCallApp {
    address public token;
    uint256 public swapoutSeq;

    constructor (address anyCallProxy, uint256 flag, address token_) AnyCallApp(anyCallProxy, flag) {
        setAdmin(msg.sender);
        token = token_;
    }

    function _swapout(uint256 tokenId) internal virtual returns (bool, bytes memory);
    function _swapin(uint256 tokenId, address receiver, bytes memory extraMsg) internal virtual returns (bool);

    event LogAnySwapOut(uint256 tokenId, address sender, address receiver, uint256 toChainID, uint256 swapoutSeq);

    function Swapout_no_fallback(uint256 tokenId, address receiver, uint256 destChainID) external payable returns (uint256) {
        (bool ok, bytes memory extraMsg) = _swapout(tokenId);
        require(ok);
        swapoutSeq++;
        bytes memory data = abi.encode(tokenId, msg.sender, receiver, swapoutSeq, extraMsg);
        _anyCall(peer[destChainID], data, address(0), destChainID);
        emit LogAnySwapOut(tokenId, msg.sender, receiver, destChainID, swapoutSeq);
        return swapoutSeq;
    }

    function _anyExecute(uint256 fromChainID, bytes calldata data) internal override returns (bool success, bytes memory result) {
        (uint256 tokenId, , address receiver,,bytes memory extraMsg) = abi.decode(
            data,
            (uint256, address, address, uint256, bytes)
        );
        require(_swapin(tokenId, receiver, extraMsg));
    }

}


// File contracts/interfaces/IMintBurn721.sol

pragma solidity ^0.8.1;

interface IMintBurn721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function mint(address account, uint256 tokenId) external;
    function burn(uint256 tokenId) external;
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File contracts/anycall_app/ERC721Gateway_MintBurn.sol
pragma solidity ^0.8.1;
contract ERC721Gateway_MintBurn is ERC721Gateway {

    constructor (address anyCallProxy, uint256 flag, address token) ERC721Gateway(anyCallProxy, flag, token) {}

    function _swapout(uint256 tokenId) internal override virtual returns (bool, bytes memory) {
        require(IMintBurn721(token).ownerOf(tokenId) == msg.sender, "not allowed");
        try IMintBurn721(token).burn(tokenId) {
            return (true, "");
        } catch {
            return (false, "");
        }
    }

    function _swapin(uint256 tokenId, address receiver, bytes memory extraMsg) internal override returns (bool) {
        try IMintBurn721(token).mint(receiver, tokenId) {
            return true;
        } catch {
            return false;
        }
    }
    
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}