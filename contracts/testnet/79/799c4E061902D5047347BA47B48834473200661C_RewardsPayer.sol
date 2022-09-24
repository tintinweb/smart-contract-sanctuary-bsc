// Deployed address: 0xa5c6666e365c2DD5059846577e9703666CD910c7

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC721P.sol";
import "./IControl.sol";
import "./IVaultRewards.sol";
import "./ILazyNFT.sol";

/// @title A contract that Calculate the Rewards per User
/// @author @Mike_Bello90
/// @notice You can use this contract to calculate the user rewards for Panoram Fees
contract RewardsPayer is ReentrancyGuard, AccessControl {
    // ***** Address relayer BSC Testnet ******
    address private relayAddress = 0x59C1E897f0A87a05B2B6f960dE5090485f86dd3D;
    // Contratos de los tokens Busd y Usdc en BSC Mainnet
    IERC20 Busd = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee); // tesnet address: 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee  Mainet: 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56
    IERC20 Usdc = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);

    IControl private controlContract =
        IControl(0x2FE3f52AA8212A57aBe42ad390144c12386a3A0c);
    IVaultRewards private VaultRewardsContract =
        IVaultRewards(0x01aaA71872f4A2483bc9a228114549Cf1634cfB9);

    uint256 private lastTimeCalcRentRewards;
    uint8 public percentageHolders = 50;
    uint8 public percentageMinters = 20;
    uint8 public percentageLenders = 30;

    /// @dev Struct para registrar y validar datos necesarios de un usuario para la entrega y calculo del Reward
    struct UserRewards {
        uint256 rewardPerBuilder;
        uint256 lastTimePayBuilder;
        uint256 rewardPerHolder;
        uint256 lastTimePayHolder;
    }

    struct UserRewardsRent {
        uint256 rewardPerRent;
        uint256 lastTimePayRent;
    }
    /// @dev salvamos la wallet del user y luego en el mapping interno salvamos la address de la collection y la estructura con sus rewards de renta por coleccion.
    mapping(address => mapping(address => UserRewardsRent))
        private collectionRewardsRentPerUser;

    // mapping to save the general user rewards for builder and Holder (contando los NFTs del user sin importar la coleccion)
    mapping(address => UserRewards) private userRewardsBH;

    // guardar el contrato de la coleccion y el contrato del vault que se usa para cada coleccion
    mapping(address => address) private collectionToVault;

    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");

    event withdrawSuccess(address indexed walletUser, uint256 amountReward);

    constructor(
        uint8 _perHolders,
        uint8 _perMinters,
        uint8 _perLenders
    ) {
        percentageHolders = _perHolders;
        percentageMinters = _perMinters;
        percentageLenders = _perLenders;

        /// @dev Por el momento se implemento el owner como quien deploya el contrato, cambiarlo a lo que sea mas adecuado antes de entrar a Produccion(Relayer)
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEV_ROLE, msg.sender);
        _setupRole(DEV_ROLE, relayAddress);
    }

    modifier onlyDev() {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("Not enough Permissions");
        }
        _;
    }

    // ***********************************************************************************************************************

    /// @dev this allow the user to withdraw his rewards if he is a Builder user
    function payBuilderReward(address _token) public nonReentrant {
        if (_token != address(Busd) && _token != address(Usdc)) {
            revert("Token Invalid");
        }
        uint256 amountReward = userRewardsBH[msg.sender].rewardPerBuilder;
        if (amountReward == 0) {
            revert("You have no rewards available");
        }
        userRewardsBH[msg.sender].rewardPerBuilder = 0;
        userRewardsBH[msg.sender].lastTimePayBuilder = block.timestamp;
        VaultRewardsContract.withdraw(amountReward, _token);
        // enviamos el dinero al usuario en el token que lo solicito.
        if (_token == address(Busd)) {
            Busd.transfer(msg.sender, amountReward);
        } else if (_token == address(Usdc)) {
            Usdc.transfer(msg.sender, amountReward);
        }
        emit withdrawSuccess(msg.sender, amountReward);
    }

    /// @dev this allow the user to withdraw his rewards per being a Holder of an NFT.
    function payHolderReward(address _token) public nonReentrant {
        if (_token != address(Busd) && _token != address(Usdc)) {
            revert("Token Invalid");
        }
        uint256 amountReward = userRewardsBH[msg.sender].rewardPerHolder;
        if (amountReward == 0) {
            revert("You have no rewards available");
        }
        userRewardsBH[msg.sender].rewardPerHolder = 0;
        userRewardsBH[msg.sender].lastTimePayHolder = block.timestamp;
        VaultRewardsContract.withdraw(amountReward, _token);
        if (_token == address(Busd)) {
            Busd.transfer(msg.sender, amountReward);
        } else if (_token == address(Usdc)) {
            Usdc.transfer(msg.sender, amountReward);
        }
        emit withdrawSuccess(msg.sender, amountReward);
    }

    /// @dev this allow the user to withdraw his rewards per Rent for each collection He holds an NFT
    function payRentReward(address _collection, address _token)
        public
        nonReentrant
    {
        if (_token != address(Busd) && _token != address(Usdc)) {
            revert("Token Invalid");
        }
        uint256 amountRentReward = collectionRewardsRentPerUser[msg.sender][
            _collection
        ].rewardPerRent;
        if (amountRentReward == 0) {
            revert("You have no rewards available");
        }
        collectionRewardsRentPerUser[msg.sender][_collection].rewardPerRent = 0;
        collectionRewardsRentPerUser[msg.sender][_collection]
            .lastTimePayRent = block.timestamp;
        //** Sacamos del vault de rentas de esta propiedad la cantidad a pagar al user.
        IVaultRewards VaultRentRewards = IVaultRewards(
            collectionToVault[_collection]
        );
        VaultRentRewards.withdraw(amountRentReward, _token);
        if (_token == address(Busd)) {
            Busd.transfer(msg.sender, amountRentReward);
        } else if (_token == address(Usdc)) {
            Usdc.transfer(msg.sender, amountRentReward);
        }
        emit withdrawSuccess(msg.sender, amountRentReward);
    }

    ///@dev Funcion para retirar todos los rewards de todas las colecciones en las que el usuario minteo o holdear nfts (buider, holder, rents).
    /// @param _collections: array con las colecciones de las que el sender minteo o tiene nfts en hold.
    /// @param _token: token en el que se retiraran los rewards (Busd o Usdc)
    function payAllRewards(address[] calldata _collections, address _token)
        public
        nonReentrant
    {
        if (_token != address(Busd) && _token != address(Usdc)) {
            revert("Token Invalid");
        }
        // recorremos todas las colecciones de las que tiene rewards para sumarlas y saber cuando debe retirar
        uint256 amountRents = 0;
        uint256 amountRentFinal = 0;
        for (uint16 i = 0; i < _collections.length; i++) {
            // reseteamos la struct a 0
            amountRents = collectionRewardsRentPerUser[msg.sender][
                _collections[i]
            ].rewardPerRent;
            amountRentFinal += amountRents;
            collectionRewardsRentPerUser[msg.sender][_collections[i]]
                .rewardPerRent = 0;
            collectionRewardsRentPerUser[msg.sender][_collections[i]]
                .lastTimePayRent = block.timestamp;

            IVaultRewards vaultRent = IVaultRewards(
                collectionToVault[_collections[i]]
            );
            vaultRent.withdraw(amountRents, _token);
        }

        uint256 amountRewards = userRewardsBH[msg.sender].rewardPerBuilder +
            userRewardsBH[msg.sender].rewardPerHolder;
        if (amountRewards == 0 && amountRents == 0) {
            revert("No Rewards to claim yet");
        }
        userRewardsBH[msg.sender].rewardPerBuilder = 0;
        userRewardsBH[msg.sender].lastTimePayBuilder = block.timestamp;
        userRewardsBH[msg.sender].rewardPerHolder = 0;
        userRewardsBH[msg.sender].lastTimePayHolder = block.timestamp;

        VaultRewardsContract.withdraw(amountRewards, _token);

        uint256 finalAmountToClaim = amountRewards + amountRentFinal;

        if (_token == address(Busd)) {
            Busd.transfer(msg.sender, finalAmountToClaim);
        } else if (_token == address(Usdc)) {
            Usdc.transfer(msg.sender, finalAmountToClaim);
        }
        emit withdrawSuccess(msg.sender, finalAmountToClaim);
    }

    // funcion que permite al Lender retirar sus rewards.
    function payLenderReward() public {}

    // ***********************************************************************************************************************

    /// @dev this function calculate the user Rewards per Builder for all the collections.
    /// @param _walletsUsers: el arreglo de wallets para los que se realizara el calculo.
    /// @param _numNFTsMinted: el numero de NFTs que minteo la wallet en todas las colecciones en las que compro nfts.
    function CalcBuilderRewardsForCollection(
        address[] calldata _walletsUsers,
        uint256[] calldata _numNFTsMinted
    ) public onlyDev {
        if (_walletsUsers.length != _numNFTsMinted.length) {
            revert("Arrays Mismatch");
        }
        uint256 ingresoTemporalDiario = VaultRewardsContract.seeDaily();
        if (ingresoTemporalDiario == 0) {
            revert("No Rewards yet");
        }
        // obtenemos el 20% de los ingresos de fees diarios para repartirlo entre los builder(minters)
        uint256 ingresoDiarioForBuilders = (ingresoTemporalDiario *
            percentageMinters) / 100;
        uint256 TotalNFTsMinteadosGeneral = controlContract.seeCounter();
        uint256 PayPerNFT = ingresoDiarioForBuilders /
            TotalNFTsMinteadosGeneral;
        for (uint16 i = 0; i < _walletsUsers.length; i++) {
            if (_numNFTsMinted[i] != 0) {
                // guardamos el calculo del reward por coleccion para cada usuario
                userRewardsBH[_walletsUsers[i]].rewardPerBuilder +=
                    _numNFTsMinted[i] *
                    PayPerNFT;
            }
        }
    }

    /// @dev this function calculate the user Rewards per Builder for all the collections.
    /// @param _walletsUsers: el arreglo de wallets para los que se realizara el calculo.
    /// @param _numNFTsHolder: el numero de NFTs que holdea la wallet en todas las colecciones en las que tiene NFTs.
    function CalcHolderRewardsForCollection(
        address[] calldata _walletsUsers,
        uint256[] calldata _numNFTsHolder
    ) public onlyDev {
        if (_walletsUsers.length != _numNFTsHolder.length) {
            revert("Array Mismatch");
        }
        uint256 ingresoTemporalDiario = VaultRewardsContract.seeDaily();
        if (ingresoTemporalDiario == 0) {
            revert("No Rewards yet");
        }
        // obtenemos el 50% de los ingresos de fees diarios para repartirlo entre los Holders
        uint256 ingresoDiarioForHolders = (ingresoTemporalDiario *
            percentageHolders) / 100;
        // Leer el total de NFTs que se han creado
        uint256 TotalNFTsGeneral = controlContract.seeCounter();
        // calculamos el reward por NFT
        uint256 PayPerNFT = ingresoDiarioForHolders / TotalNFTsGeneral;
        for (uint16 i = 0; i < _walletsUsers.length; i++) {
            if (_numNFTsHolder[i] != 0) {
                // guardamos el calculo del reward por coleccion para cada usuario
                userRewardsBH[_walletsUsers[i]].rewardPerHolder +=
                    _numNFTsHolder[i] *
                    PayPerNFT;
            }
        }
    }

    // funcion para calcular los rewards por renta el autotask la llamara cada 30 dias.
    function CalcRentRewardsForCollection(
        address _collection,
        address[] calldata _walletsUsers,
        uint256[] calldata _numNFTsHolder
    ) public onlyDev {
        if (_walletsUsers.length != _numNFTsHolder.length) {
            revert("Array Mismatch");
        }
        ILazyNFT CollectionContract = ILazyNFT(_collection);
        // Leer el mapping para obtener la address del vault de renta de la propiedad
        IVaultRewards vaultRentRewards = IVaultRewards(
            collectionToVault[_collection]
        );
        // Validamos que hayan pasado 30 dias desde la ultima vez del calculo de rewards por renta.
        uint256 timeCheckPass30days = lastTimeCalcRentRewards + 30 days;
        if (block.timestamp < timeCheckPass30days) {
            revert("You must wait at least 30 days to get your Rewards");
        }
        lastTimeCalcRentRewards = block.timestamp;
        // obtenemos los ingresos mensuales de las rentas, todo lo que hay en el vault
        // se reparte como reward por rentas entre los holders del NFT de la propiedad.
        // validar la forma de leer el total acumulado en el vault de rentas.
        // cambiar el nombre de la funcion a seeMonthly() esta nos regresa el total acumulado en el vault de esta propiedad
        uint256 monthlyRentIncome = vaultRentRewards.seeDaily();
        if (monthlyRentIncome == 0) {
            revert("No Monthly Rental Income Yet");
        }
        // leemos el total de NFTs de esa coleccion (propiedad)
        uint256 totalNFtsxCollection = CollectionContract.totalSupply();
        uint256 PayPerNFT = monthlyRentIncome / totalNFtsxCollection;
        for (uint16 i = 0; i < _walletsUsers.length; i++) {
            if (_numNFTsHolder[i] != 0) {
                // guardamos los rewards que le tocan por renta en la Struct de rewards
                collectionRewardsRentPerUser[_walletsUsers[i]][_collection]
                    .rewardPerRent += _numNFTsHolder[i] * PayPerNFT;
            }
        }
    }

    function CalcLenderRewardsForCollection(
        address _Collection,
        address[] calldata _walletsUsers
    ) public onlyDev {
        // ***** PENDIENTE ****
        // al lender tambien se le pagara por coleccion o como funcionaria?
        // tendriamos que saber cuanto presto para pagarle un porcentaje de lo que presto?
        // este porcentaje saldria del 15% del pool de rewards?
        // y si este 15% no alcanza para pagar a todos lender su porcentaje acordado?
    }

    // **********************************************************************************************************************

    ///@dev funciones para actualizar los porcentajes repartidos de los fees.
    // Estas funciones tienes que dar una suma 100% en total porque ya se tiene separado el 50% de panoram
    // en multisign.
    function updatePercentageHolders(uint8 _newPercentage) public onlyDev {
        percentageHolders = _newPercentage;
    }

    function updatePercentageMinters(uint8 _newPercentage) public onlyDev {
        percentageMinters = _newPercentage;
    }

    function updatePercentageLenders(uint8 _newPercentage) public onlyDev {
        percentageLenders = _newPercentage;
    }

    /// @dev this function is for obtain the user info struct per wallet
    function getRewardsPerUserRent(address _walletUser, address _Collection)
        public
        view
        returns (UserRewardsRent memory)
    {
        // Regresamos los datos de las structuras de los rewards para Builder, Holder y Rentas.
        return collectionRewardsRentPerUser[_walletUser][_Collection];
    }

    function getRewardsPerUserBH(address _walletUser)
        public
        view
        returns (UserRewards memory)
    {
        return userRewardsBH[_walletUser];
    }

    // Funcion que actualiza el mapping que guarda la address de la coleccion y la address de su respectivo vault.
    function saveCollectionToVault(address _Collection, address _Vault)
        public
        onlyDev
    {
        collectionToVault[_Collection] = _Vault;
    }

    // **** FUNCIONES SOLO PARA DESARROLLO.
    function clearRewards(address _wallet, address _collection) public {
        userRewardsBH[_wallet].rewardPerBuilder = 0;
        userRewardsBH[_wallet].lastTimePayBuilder = 0;
        userRewardsBH[_wallet].rewardPerHolder = 0;
        userRewardsBH[_wallet].lastTimePayHolder = 0;

        collectionRewardsRentPerUser[_wallet][_collection].rewardPerRent = 0;
        collectionRewardsRentPerUser[_wallet][_collection].lastTimePayRent = 0;
    }

    function updateContracts(address _control, address _vault) public {
        controlContract = IControl(_control);
        VaultRewardsContract = IVaultRewards(_vault);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IERC721P is IERC165 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

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

    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);

    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);

    // regresa el timestamp del tiempo que tiene holdeando el nft
    function holdInfo(uint256 tokenId) external view returns (uint32);

    // regresa el total de nfts que minteo(es Builder) ese owner por coleccion
    function mintInfo(address _owner) external view returns (uint32);

    // para saber si es holder retorna un arr con los ids de los token de los que es dueño y el total de los nft que tiene _length en la coleccion
    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory, uint256 _length);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface IControl {
    // retorna coleccion, id token, owner y fecha en que compro.
    // le envio la collection y el idtoken
    // en base al totalsuply del lazymint contract -  consultar este funcion para sacar los wallets que
    // tienen nfts, el
    function getNFTInfo(address _collection, uint256 _id)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint32
        );

    function addRegistry(
        address _collection,
        uint256 _nftId,
        address _wallet,
        uint32 _timestamp
    ) external;

    function updateRegistry(
        address _collection,
        uint256 _nftId,
        address _wallet,
        uint32 _timestamp
    ) external;

    function removeRegistry(address _collection, uint256 _nftId) external;

    function addCounter() external; // usada por el market

    // contador que nos da el numero de nfts minteados sin importar colleccion.
    function seeCounter() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILazyNFT {
    function redeem(address _redeem, uint256 _amount)
        external
        returns (uint256);

    function preSale(address _redeem, uint256 _amount)
        external
        returns (uint256);

    function tokenURI(uint256 tokenId)
        external
        view
        returns (string memory base);

    function walletOfOwner(address _owner)
        external
        view
        returns (uint256[] memory, uint256 _length);

    function totalSupply() external view returns (uint256);

    function maxSupply() external view returns (uint256);

    function getPrice() external view returns (uint256);

    function getPresale() external view returns (uint256);

    function getPresaleStatus() external view returns (bool);

    function nftcost() external view returns (uint256 _price);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IVaultRewards {
    function deposit(uint256 _amount, address _token) external;

    // mando la cantidad a retirar y la address del token(busd, usdc)mandar la address de bsud
    // el vault envia el money al contrato de rewards, y del contrato del reward ya se lo mando al usuario.
    function withdraw(uint256 amount, address _token) external;

    function setStrategyContract(address) external;

    function setmultisig(address) external;

    function withdrawAll() external;

    // regresa el conteo de los ingresos al vault de rewards del dia. solo para los fees de holder
    // los de panoram ya no se ingresan en el vault de rewards por lo que los porcentajes cambiarian
    function seeDaily() external view returns (uint256 tempRewards);
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
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

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
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

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}