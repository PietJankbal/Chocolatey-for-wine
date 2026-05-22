/* Stolen and adapted from:
 *https://github.com/sander110419/lightroom-cc-on-linux/blob/main/stubs/sources/adobe_e26b366d.c
 *
 *i686-w64-mingw32-gcc/x86-w64-mingw32-gcc -shared -Wl,--kill-at -nostartfiles -O2 -s  untitled.c -lole32
 *
 * Stub COM server for Adobe-internal CLSID
 *   {e26b366d-f998-43ce-836f-cb6d904432b0}
 *
 * Adobe Lightroom CC under Wine asks for this class via CoCreateInstance().
 * Wine's OLE replies "class not registered" (REGDB_E_CLASSNOTREG), AgKernel
 * doesn't null-check the returned IUnknown*, and lightroom.exe derefs NULL
 * (crash at lightroom.exe+0x28231C with all-zero registers).
 *
 * We don't know which Adobe interface they want, so we expose a minimal
 * IUnknown:
 *   - QueryInterface returns S_OK only for IID_IUnknown; E_NOINTERFACE for
 *     anything else (including the Adobe interface they really wanted).
 *   - AddRef / Release behave normally.
 *
 * If LR null-checks QI() failures, that's a clean fallback path. If it
 * dereferences a null returned object pointer instead, this still beats
 * REGDB_E_CLASSNOTREG because at least CoCreateInstance() hands them a
 * valid IUnknown* — they'll just discover later they can't QI the iface.
 *
 * DllRegisterServer writes:
 *   HKLM\Software\Classes\CLSID\{e26b366d-...}\        (default) = friendly
 *   HKLM\Software\Classes\CLSID\{e26b366d-...}\InprocServer32 = adobe_e26b366d.dll
 *     ThreadingModel = Both
 */
 
#define COBJMACROS
#define INITGUID
#include <stdio.h>
#include <windows.h>
#include <objbase.h>
#include <unknwn.h>




// ===== GUIDs =====
//static const GUID CLSID_AdobeE26B366D = createguid("{f988B571-EC89-11CF-9C00-00AA00A14F56}");// clsid;
  //  {0xe26b366d, 0xf998, 0x43ce, {0x83,0x6f,0xcb,0x6d,0x90,0x44,0x32,0xb0}};

/* Adobe-internal interface requested via CoCreateInstanceEx MULTI_QI.
 * Unknown layout — we expose a generous 20-slot stub vtable.
 */
static const GUID IID_AdobeA8BB5D22 =
    {0xa8bb5d22, 0x3144, 0x4a7b, {0x93,0xcd,0xf3,0x4a,0x16,0xbe,0x51,0x3a}};

// ===== Adobe stub object with extended 20-slot vtable =====
/*
 * The IUnknown trio (QueryInterface / AddRef / Release) occupy slots 0..2.
 * Slots 3..19 are generic no-op stubs that:
 *   - take (this, void*, void*, void*, void*, void*, void*, void*) — 7 generic args
 *     after the implicit `this`. x86_64 MS ABI passes the first 4 args in
 *     RCX/RDX/R8/R9, additional args on the stack; extra trailing args we
 *     never touch are harmless.
 *   - return S_OK (0).
 *   - never deref any argument.
 *
 * Adobe's crash is `call *0x18(%rax)` => slot index 3, the first non-IUnknown
 * slot. A stub returning 0 satisfies the call and keeps execution going.
 */

typedef HRESULT (__stdcall *AdobeStubMethod)(void *This,
                                             void *a, void *b, void *c,
                                             void *d, void *e, void *f, void *g);

typedef struct AdobeStubVtbl {
    HRESULT (__stdcall *QueryInterface)(void *This, REFIID riid, void **ppv);
    ULONG   (__stdcall *AddRef)(void *This);
    ULONG   (__stdcall *Release)(void *This);
    AdobeStubMethod Method03;
    AdobeStubMethod Method04;
    AdobeStubMethod Method05;
    AdobeStubMethod Method06;
    AdobeStubMethod Method07;
    AdobeStubMethod Method08;
    AdobeStubMethod Method09;
    AdobeStubMethod Method10;
    AdobeStubMethod Method11;
    AdobeStubMethod Method12;
    AdobeStubMethod Method13;
    AdobeStubMethod Method14;
    AdobeStubMethod Method15;
    AdobeStubMethod Method16;
    AdobeStubMethod Method17;
    AdobeStubMethod Method18;
    AdobeStubMethod Method19;
} AdobeStubVtbl;

typedef struct AdobeStubObj {
    const AdobeStubVtbl *lpVtbl;
    LONG ref;
} AdobeStubObj;

static HRESULT __stdcall Stub_QueryInterface(void *This, REFIID riid, void **ppv) {
    AdobeStubObj *obj = (AdobeStubObj*)This;
    if (!ppv) return E_POINTER;
    if (IsEqualIID(riid, &IID_IUnknown) ||
        IsEqualIID(riid, &IID_AdobeA8BB5D22) || 1)  //HACK
    {
        *ppv = This;
        InterlockedIncrement(&obj->ref);
        return S_OK;
    }
    /* Any other Adobe-private interface — let the caller see E_NOINTERFACE. */
    *ppv = NULL;
    return E_NOINTERFACE;
}

static ULONG __stdcall Stub_AddRef(void *This) {
    return InterlockedIncrement(&((AdobeStubObj*)This)->ref);
}

static ULONG __stdcall Stub_Release(void *This) {
    LONG r = InterlockedDecrement(&((AdobeStubObj*)This)->ref);
    if (r == 0) HeapFree(GetProcessHeap(), 0, This);
    return r;
}

/* Generic fill-outs slot.
 *
 * Adobe Lightroom calls methods on this stub that have [out] interface-pointer
 * arguments, e.g.
 *     HRESULT GetFoo([in] this, [in] DWORD, ..., [out] IFoo **ppOut);
 * Adobe expects *ppOut to be a valid pointer afterward. If we leave it NULL,
 * Adobe dereferences it (`mov (%rcx),%rax`) and crashes (observed at
 * lightroom.exe+0x28231C).
 *
 * Strategy: for each generic arg we receive, if it looks like a non-null
 * pointer-to-pointer, write `This` (our stub) into *p. That way:
 *   - Adobe gets a non-null interface back, pointing at OUR stub.
 *   - Any subsequent vtable call on that "interface" hits our 20-slot vtable,
 *     which is also no-op-safe.
 *
 * We can't tell which args are [in] vs [out] at runtime. Writing through an
 * [in] pointer that happens to be writable is usually fine: at worst we
 * overwrite an in-value the callee already consumed.
 *
 * SEH protection (__try/__except) guards each write so an unmapped or
 * read-only address never propagates an AV.
 *
 * x86_64 Microsoft ABI: args 1..4 are in RCX/RDX/R8/R9. With `This` taking
 * RCX, the first 3 generic args (a,b,c) are in RDX/R8/R9 (registers, no stack
 * slot needed for them by callee), and d..g spill onto the stack. The callee
 * has 32 bytes of "shadow space" reserved by the caller. Declaring 7 generic
 * args matches what real Adobe interfaces would pass in registers/stack.
 */
/* mingw-w64 gcc 13-win32 doesn't expose __try / __except as keywords without
 * a different SEH model than this toolchain ships. Use IsBadWritePtr as a
 * best-effort probe instead. Deprecated, yes, but for this use case (decide
 * whether an in-arg is a writable pointer-to-pointer that we should treat as
 * an [out] slot) it's exactly the right tool. */
static HRESULT __stdcall Stub_FillOuts(void *This,
                                       void *a, void *b, void *c,
                                       void *d, void *e, void *f, void *g) {
    /* Return S_FALSE (1) so Adobe's "if(ebx == 1) goto error" branch fires.
     * Pattern in lightroom.exe+0x140282210:
     *   call vtbl[7]               // method 7 -- our stub
     *   mov ebx, eax               // ebx = return
     *   ...
     *   cmp ebx, 1
     *   je   error_path            // S_FALSE = 1 forces error path
     *   ...uses [rbp-0x30] which would otherwise be NULL...crash
     */
    (void)This; (void)a; (void)b; (void)c; (void)d; (void)e; (void)f; (void)g;
    return 1;   /* S_FALSE */
}

static const AdobeStubVtbl g_stub_vtbl = {
    Stub_QueryInterface, Stub_AddRef, Stub_Release,
    Stub_FillOuts, Stub_FillOuts, Stub_FillOuts, Stub_FillOuts, Stub_FillOuts,
    Stub_FillOuts, Stub_FillOuts, Stub_FillOuts, Stub_FillOuts, Stub_FillOuts,
    Stub_FillOuts, Stub_FillOuts, Stub_FillOuts, Stub_FillOuts, Stub_FillOuts,
    Stub_FillOuts, Stub_FillOuts
};

static AdobeStubObj *create_stub(void) {
    AdobeStubObj *obj = HeapAlloc(GetProcessHeap(), 0, sizeof(*obj));
    if (!obj) return NULL;
    obj->lpVtbl = &g_stub_vtbl;
    obj->ref = 1;
    return obj;
}

// ===== IClassFactory =====
typedef struct AdobeStubCF {
    const IClassFactoryVtbl *lpVtbl;
    LONG ref;
} AdobeStubCF;

static HRESULT STDMETHODCALLTYPE CF_QueryInterface(IClassFactory *This, REFIID riid, void **ppv) {
    if (!ppv) return E_POINTER;
    if (IsEqualIID(riid, &IID_IUnknown) || IsEqualIID(riid, &IID_IClassFactory)) {
        *ppv = This;
        This->lpVtbl->AddRef(This);
        return S_OK;
    }
    *ppv = NULL;
    return E_NOINTERFACE;
}
static ULONG STDMETHODCALLTYPE CF_AddRef(IClassFactory *This) {
    return InterlockedIncrement(&((AdobeStubCF*)This)->ref);
}
static ULONG STDMETHODCALLTYPE CF_Release(IClassFactory *This) {
    // Singleton — pin at 1.
    LONG r = InterlockedDecrement(&((AdobeStubCF*)This)->ref);
    if (r < 1) ((AdobeStubCF*)This)->ref = 1;
    return 1;
}
static HRESULT STDMETHODCALLTYPE CF_CreateInstance(IClassFactory *This, IUnknown *pUnkOuter, REFIID riid, void **ppv) {
    (void)This;
    if (!ppv) return E_POINTER;
    *ppv = NULL;
    if (pUnkOuter) return CLASS_E_NOAGGREGATION;
    AdobeStubObj *obj = create_stub();
    if (!obj) return E_OUTOFMEMORY;
    HRESULT hr = obj->lpVtbl->QueryInterface(obj, riid, ppv);
    obj->lpVtbl->Release(obj);
    return hr;
}
static HRESULT STDMETHODCALLTYPE CF_LockServer(IClassFactory *This, BOOL fLock) {
    (void)This; (void)fLock;
    return S_OK;
}

static const IClassFactoryVtbl g_CF_vtbl = {
    CF_QueryInterface, CF_AddRef, CF_Release,
    CF_CreateInstance, CF_LockServer
};
static AdobeStubCF g_class_factory = { &g_CF_vtbl, 1 };

// ===== DLL entry points =====
__declspec(dllexport) HRESULT WINAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, void **ppv) {

const char *strCLSID = "{e26b366d-f998-43ce-836f-cb6d904432b0}";
OLECHAR wsz[64];
GUID guid;

    if(MultiByteToWideChar(CP_ACP, 0, strCLSID, -1, wsz, _countof(wsz)) == 0) {fprintf(stderr,"error!!!");return 5;} 

    if (CLSIDFromString(wsz, &guid) != S_OK) {fprintf(stderr,"error!!!"); return 5;}


    if (!ppv) return E_POINTER;
    *ppv = NULL;
    if (IsEqualCLSID(rclsid, &guid)) {
        return g_class_factory.lpVtbl->QueryInterface((IClassFactory*)&g_class_factory, riid, ppv);
    }
    return CLASS_E_CLASSNOTAVAILABLE;
}

__declspec(dllexport) HRESULT WINAPI DllCanUnloadNow(void) {
    return S_FALSE;
}

static LONG set_reg_sz(HKEY root, const char *subkey, const char *value, const char *data) {
    HKEY h;
    LONG err = RegCreateKeyExA(root, subkey, 0, NULL, 0, KEY_WRITE, NULL, &h, NULL);
    if (err != ERROR_SUCCESS) return err;
    err = RegSetValueExA(h, value, 0, REG_SZ, (const BYTE*)data, (DWORD)(strlen(data) + 1));
    RegCloseKey(h);
    return err;
}

__declspec(dllexport) HRESULT WINAPI DllRegisterServer(void) {
    const char *clsid_key  = "Software\\Classes\\CLSID\\{e26b366d-f998-43ce-836f-cb6d904432b0}";
    const char *inproc_key = "Software\\Classes\\CLSID\\{e26b366d-f998-43ce-836f-cb6d904432b0}\\InprocServer32";
    if (set_reg_sz(HKEY_LOCAL_MACHINE, clsid_key,  NULL,             " stub (wine)") != ERROR_SUCCESS) return E_FAIL;
    if (set_reg_sz(HKEY_LOCAL_MACHINE, inproc_key, NULL,             "stubdll.dll")         != ERROR_SUCCESS) return E_FAIL;
    if (set_reg_sz(HKEY_LOCAL_MACHINE, inproc_key, "ThreadingModel", "Both")                       != ERROR_SUCCESS) return E_FAIL;
    return S_OK;
}

__declspec(dllexport) HRESULT WINAPI DllUnregisterServer(void) {
    RegDeleteKeyA(HKEY_LOCAL_MACHINE,
        "Software\\Classes\\CLSID\\{e26b366d-f998-43ce-836f-cb6d904432b0}\\InprocServer32");
    RegDeleteKeyA(HKEY_LOCAL_MACHINE,
        "Software\\Classes\\CLSID\\{e26b366d-f998-43ce-836f-cb6d904432b0}");
    return S_OK;
}

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD reason, LPVOID reserved) {
    (void)hinst; (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) DisableThreadLibraryCalls(hinst);
    return TRUE;
}
