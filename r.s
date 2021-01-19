using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MappingScript : MonoBehaviour
{
    // some condition
    bool cond;

    // public gameObject of key point
    public GameObject originThumbRootGameObject;
    public GameObject originThumbMidGameObject;
    public GameObject originThumbTipGameObject;

    // public gameObject of key point
    public GameObject originArmRootGameObject;
    public GameObject originArmMidGameObject;
    public GameObject originArmTipGameObject;

    // public gameObject of key point
    private GameObject savedThumbRootGameObject;
    private GameObject savedThumbMidGameObject;
    private GameObject savedThumbTipGameObject;

    // public gameObject of key point
    private GameObject savedArmRootGameObject;
    private GameObject savedArmMidGameObject;
    private GameObject savedArmTipGameObject;

    // control point of thumb
    public GameObject controlWristPointGameObject;
    public GameObject controlForeArmPointGameObject;

    // Start is called before the first frame update
    void Start()
    {
        cond = false;
    }

    // Update is called once per frame
    void Update()
    {
        if(!cond)
        {
            try
            {
                saveDefaultArmPos();
                saveDefaultThumbPos();
                cond = true;
            }
            catch
            {
                Debug.Log("NotSign");
            }
        }
        if(cond)
        {
            updateControlPoint(ref controlWristPointGameObject, originArmRootGameObject,
                                originThumbRootGameObject, originThumbMidGameObject,
                                savedThumbRootGameObject, savedThumbMidGameObject);
        }
    }

    // copy from t2 to t1
    void CopyTransform(ref Transform t1, Transform t2)
    {
        Vector3 newPosition = new Vector3(t2.position.x, t2.position.y, t2.position.z);
        t1.localPosition = newPosition;
        Quaternion newRotation = new Quaternion(t2.rotation.x, t2.rotation.y, t2.rotation.z,t2.rotation.w);
        t1.localRotation = newRotation;
        Vector3 newScale = new Vector3(t2.localScale.x, t2.localScale.y, t2.localScale.z);
        t1.localScale = newScale;
    }

    void saveDefaultThumbPos()
    {
        saveDefaultPosSingle(ref savedThumbRootGameObject, ref originThumbRootGameObject);
        saveDefaultPosSingle(ref savedThumbMidGameObject, ref originThumbMidGameObject);
        saveDefaultPosSingle(ref savedThumbTipGameObject, ref originThumbTipGameObject);
    }

    void saveDefaultArmPos()
    {
        saveDefaultPosSingle(ref savedArmRootGameObject, ref originArmRootGameObject);
        saveDefaultPosSingle(ref savedArmMidGameObject, ref originArmMidGameObject);
        saveDefaultPosSingle(ref savedArmTipGameObject, ref originArmTipGameObject);
    }
    // same origin to storage
    void saveDefaultPosSingle(ref GameObject savedGameObject, ref GameObject originGameObject)
    {
        savedGameObject = new GameObject();
        Transform savedGameObjectTransform = savedGameObject.transform;
        CopyTransform(ref savedGameObjectTransform, originGameObject.transform);
    }

    void updateControlPoint(ref GameObject CtrlPt, GameObject rootObj, GameObject ori0, GameObject ori1, GameObject src0, GameObject src1)
    {// rootObj: moving arms's root; src0.transform: fixed thumb root; ori1.transform: ori1.transform.position: the "GOING TO MOVED" arm mid
        CtrlPt.transform.position = coordTransform(rootObj.transform, src0.transform, (ori1.transform.position));
    }

    Matrix4x4 getTransformMatrix(Transform t0, Transform t1) // T0: identical (src), T1: new matrix
    {   // https://docs.unity3d.com/ScriptReference/Matrix4x4.SetColumn.html
        Matrix4x4 resultMatrix = new Matrix4x4();
        resultMatrix.SetColumn(0, t1.right);
        resultMatrix.SetColumn(1, t1.up);
        resultMatrix.SetColumn(2, t1.forward);
        resultMatrix.SetColumn(3, new Vector4(0, 0, 0, 1));

        return resultMatrix;
    }

    Vector3 worldToLocalCoord(Transform t, Vector3 worldCoordPos)
    {
        Matrix4x4 transformMatrix = t.worldToLocalMatrix;
        return transformMatrix.MultiplyPoint(worldCoordPos);
    }

    Vector3 localToWorldCoord(Transform t, Vector3 localCoordPos)
    {
        Matrix4x4 transformMatrix = t.localToWorldMatrix;
        return transformMatrix.MultiplyPoint(localCoordPos);
    }
    // Set a world coordinate point in t1 axis, transform it into identical location in t0 coordinate, they get its world coordinate position
    Vector3 coordTransform(Transform t0, Transform t1, Vector3 worldCoordPos)
    {
        Vector3 localCoordPos = worldToLocalCoord(t1, worldCoordPos);
        return localToWorldCoord(t0, localCoordPos*3);
    }
}
