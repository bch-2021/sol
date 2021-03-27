// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Tracking is Ownable {
    /// @notice Transfer types
    enum ProductTransferTypes { Manufacture, Transport, Realization }

    /// @notice Organization information
    struct Organization {
        string name;
        string headquarters;
        string description;
    }

    /// @notice The point at which the products will be delivered
    struct Point {
        string name;
        string country;
        string city;
        string pointAddress;
        address pointOwner;
    }

    /// @notice Information about product that transferred to the some point
    struct ProductTransfer {
        uint256 pointId;
        uint256 date;
        string link;
        ProductTransferTypes transferType;
    }

    Organization public organization;

    Point[] public points;
    ProductTransfer[] public productTransfers;

    uint256 public pointsTotal = 0;
    uint256 public productTransfersTotal = 0;

    /// @notice Mapping between batchNumber and ProductTransfer numbers
    mapping(string => uint256[]) public batchNumberToProductTransfers;

    /// @notice Setup organization info on contract deploy
    /// @param _name Info. Real name
    /// @param _headquarters Info. Real headquarters
    /// @param _description Info. Description for organization
    constructor(string memory _name, string memory _headquarters, string memory _description) {
        organization = Organization({
            name: _name,
            headquarters: _headquarters,
            description: _description
        });
    }

    /// @param _name Info. Real point name (Fabric, Retail point, Сustoms)
    /// @param _country Info. Real address
    /// @param _city Info. Real address
    /// @param _pointAddress Info. Real address
    /// @param _pointOwner Address that can create product transfer
    function createPoint(
        string memory _name,
        string memory _country,
        string memory _city,
        string memory _pointAddress,
        address _pointOwner
    ) external onlyOwner {
        Point memory _point = Point({
            name: _name,
            country: _country,
            city: _city,
            pointAddress: _pointAddress,
            pointOwner: _pointOwner
        });

        points.push(_point);
        pointsTotal += 1;
    }

    /// @notice Transfer point ownership. Only point owner address can create product transfer
    /// @param _pointId Point identificator
    /// @param _newPointOwner New point ownership address
    function transferPointOwnership(uint256 _pointId, address _newPointOwner) external onlyOwner {
        require(points.length > _pointId, "[E-84] - Invalid point identifier.");
        points[_pointId].pointOwner = _newPointOwner;
    }

    /// @notice Create product transaction. Related to Point.
    /// @param _pointId Point identificator
    /// @param _link Link to product serial numbers on IPFS
    /// @param _transferType One of transfer types
    /// @param _batchNumber Batch number
    function createProductTransfer(
        uint256 _pointId,
        string memory _link,
        ProductTransferTypes _transferType,
        string memory _batchNumber
    ) external {
        require(points.length > _pointId, "[E-87] - Invalid point identifier.");
        require(points[_pointId].pointOwner == msg.sender, "[E-88] - You can't create transfer for this point.");

        ProductTransfer memory _productPoint = ProductTransfer({
            pointId: _pointId,
            date: block.timestamp,
            link: _link,
            transferType: _transferType
        });
        productTransfers.push(_productPoint);
        productTransfersTotal += 1;

        batchNumberToProductTransfers[_batchNumber].push(productTransfers.length - 1);
    }

    /// @param _batchNumber Batch number of the product transfer
    /// @return Product transfer for selected batch number
    function getInfoByBatchNumber(string memory _batchNumber) external view returns(ProductTransfer[] memory) {
        uint256[] memory _productTransferNums = batchNumberToProductTransfers[_batchNumber];
        ProductTransfer[] memory _productTransfers = new ProductTransfer[](_productTransferNums.length);

        for (uint256 i = 0; i < _productTransferNums.length; i++) {
            _productTransfers[i] = productTransfers[_productTransferNums[i]];
        }
        return _productTransfers;
    }
}
