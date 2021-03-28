// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./IERCTracking.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERCTracking
contract ERCTracking is IERCTracking, Ownable {
    /// @notice Organization information
    struct Organization {
        string name;
        string headquarters;
        string description;
    }

    /// @notice The point at which the products will be delivered
    struct Point {
        string name;
        string pointAddress;
        address pointOwner;
    }

    /// @notice Info about contract owner company
    Organization public organization;

    /// @notice Contain all points
    Point[] public points;

    /// @notice Contain all product transfer
    ProductTransfer[] public productTransfers;

    /// @notice Batch numbers of productTransfers
    string[] public batchNumbers;

    /// @notice Transfer types (0 => Manufacture, 1 => Transportation, 2 => Retail...)
    uint256[] public transferTypes;

    /// @notice Total points count
    uint256 public pointsTotal = 0;

    /// @notice Total productTransfers count
    uint256 public productTransfersTotal = 0;

    mapping(string => uint256[]) batchNumberToProductTransfers;

    /// @notice Setup organization info on contract deploy
    /// @param _name Info. Real name
    /// @param _headquarters Info. Real headquarters
    /// @param _description Info. Description for organization
    /// @param _transferTypes Types for product transfers (Manufacture, Transportation, Retail...)
    constructor(
        string memory _name,
        string memory _headquarters,
        string memory _description,
        uint256[] memory _transferTypes
    ) {
        organization = Organization({
            name: _name,
            headquarters: _headquarters,
            description: _description
        });

        transferTypes = _transferTypes;
    }

    /// @param _name Info. Real point name (Fabric, Retail point...)
    /// @param _pointAddress Info. Real address
    /// @param _pointOwner Address that can create product transfer
    function createPoint(string memory _name, string memory _pointAddress, address _pointOwner) external override onlyOwner {
        Point memory _point = Point({
            name: _name,
            pointAddress: _pointAddress,
            pointOwner: _pointOwner
        });

        points.push(_point);
        pointsTotal += 1;
    }

    /// @notice Update point information
    /// @param _pointId Point ID
    /// @param _name New name
    /// @param _pointAddress New address
    function updatePoint(
        uint256 _pointId,
        string memory _name,
        string memory _pointAddress
    ) external override onlyOwner {
        require(points.length > _pointId, "[E-85] - Invalid point identifier.");
        Point memory _point = points[_pointId];

        _point.name = _name;
        _point.pointAddress = _pointAddress;

        points[_pointId] = _point;
    }

    /// @notice Transfer point ownership. Only point owner address can create product transfer
    /// @param _pointId Point identificator
    /// @param _newPointOwner New point ownership address
    function transferPointOwnership(uint256 _pointId, address _newPointOwner) external override onlyOwner {
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
        uint256 _transferType,
        string memory _batchNumber
    ) external override {
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

        string[] memory _batchNumbers = batchNumbers;
        bool _isBatchNumberExist = false;
        for (uint256 i = 0; i < _batchNumbers.length; i++) {
            if (keccak256(abi.encodePacked(_batchNumbers[i])) == keccak256(abi.encodePacked(_batchNumber))) {
                _isBatchNumberExist = true;
                break;
            }
        }

        if (!_isBatchNumberExist) {
            batchNumbers.push(_batchNumber);
        }
    }

    /// @param _batchNumber Batch number of the product transfer
    /// @return Product transfer for selected batch number
    function getInfoByBatchNumber(string memory _batchNumber) external view override returns(ProductTransfer[] memory) {
        uint256[] memory _productTransferNums = batchNumberToProductTransfers[_batchNumber];
        ProductTransfer[] memory _productTransfers = new ProductTransfer[](_productTransferNums.length);

        for (uint256 i = 0; i < _productTransferNums.length; i++) {
            _productTransfers[i] = productTransfers[_productTransferNums[i]];
        }
        return _productTransfers;
    }

    /// @return All batch numbers
    function getBatchNumbers() external view override returns(string[] memory) {
        return batchNumbers;
    }
}
